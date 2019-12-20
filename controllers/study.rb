paths study: '/study/:class/:group', # get, post
  study2: '/study2',
  api_drill_sentence: '/api/drill_sentence'

get :study do
  protect!

  progresses = Progress.public_send(safe_group(params[:group])).
                        public_send(safe_type(params[:class])).
                        where(user: current_user)
  @count = progresses.count
  @progress = progresses.order('RANDOM()').first

  if @progress.present?
    @title = @progress.title
    slim :study
  else
    flash[:notice] = "No more #{params[:class]} in \"#{params[:group]}\" group"
    redirect path_to(:index)
  end
end

post :study do
  protect!

  p = Progress.find(params[:id])
  halt(403, 'Forbidden') if p.user_id != current_user.id
  halt(400, 'Element not found') unless p.present?

  p.answer!(params[:answer])

  redirect path_to(:study).with(safe_type(params[:class]), safe_group(params[:group]))
end

get :study2 do
  protect!

  slim :study2
end

post :study2 do
  protect!

  progresses = {}
  params[:answers].each do |i, a|
    a['progress'] = Progress.find_or_initialize_by(seq: a['seq'], title: a['base'], user: current_user)
  end

  params[:answers].each do |i,a|
    next if a['answer'] == 'burned'
    a['progress'].answer!(a['answer'])
  end

  return 'ok'
end

get :api_drill_sentence do
  protect!

  drill = Drill.find(params[:id])

  sAT = Sentence.arel_table
  srAT = SentenceReview.arel_table

  # Left outer join with two conditions:
  #      L-O-JOIN ON s.id = sr.sentence_id AND sr.user_id == current_user.id WHERE sr 'is empty'
  sentence_without_any_reviews = drill.sentences.joins(
    sAT.create_join(
       srAT,
       sAT.create_on(  srAT[:sentence_id].eq(sAT[:id]).and(srAT[:user_id].eq(current_user.id))  ),
       Arel::Nodes::OuterJoin
    )
  ).where(sentence_reviews: {id: nil}).first

  sentence = sentence_without_any_reviews ||
    SentenceReview.joins(:sentence).merge( Sentence.where(drill: drill) ).where(user: current_user).order(reviewed_at :asc).first.try(:sentence)

  halt(400, 'Element not found') unless sentence.present?

  return {
      sentence: sentence.structure,
      english: sentence.english,
      j: Collector.new(current_user, words: Word.where(seq: sentence.words.map(&:seq))).to_hash
  }.to_json

end
