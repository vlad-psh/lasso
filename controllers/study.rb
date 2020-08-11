paths study: '/study/:class/:group', # get, post
  study2: '/study2',
  api_question: '/api/question'

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
    next if a['answer'] == 'burned' # why??
    a['progress'].answer!(a['answer'], is_drill: params[:drill].present?)
  end

  if params[:sentence_id].present?
    review = SentenceReview.find_or_initialize_by(sentence_id: params[:sentence_id], user: current_user)
    review.update(reviewed_at: DateTime.now)
  end

  return 'ok'
end

def get_drill_sentence(drill_id)
  drill = Drill.find(drill_id)

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
  ).where(sentence_reviews: {id: nil}).sample

  sentence = sentence_without_any_reviews ||
    SentenceReview.joins(:sentence).merge( Sentence.where(drill: drill) ).where(user: current_user).order(reviewed_at: :asc).first.try(:sentence)

  halt(400, 'Element not found') unless sentence.present?

  return {
      sentence_id: sentence.id,
      sentence: sentence.structure,
      english: sentence.english,
      j: Collector.new(current_user, words: Word.where(seq: sentence.words.map(&:seq))).to_hash
  }.to_json

end

def get_drill_word(drill_id, fresh = false, allow_recursion = true)
  drill = Drill.find(drill_id)

  # Try to find failed cards
  progress ||= SrsProgress.includes(:progress) \
    .joins(:progress) \
    .merge(drill.progresses) \
    .where(learning_type: :reading_question, leitner_box: nil) \
    .where.not(leitner_last_reviewed_at_session: [current_user.leitner_session, nil, 10]) \
    .order(id: :asc) \
    .first.try(:progress)

  if current_user.leitner_fresh < 5 && fresh && !progress.persent?
    progress ||= SrsProgress.includes(:progress) \
      .joins(:progress) \
      .merge(drill.progresses) \
      .where(learning_type: :reading_question, leitner_last_reviewed_at_session: nil) \
      .order(id: :asc) \
      .first.try(:progress)
    # Next try to select cards without any SrsProgress records
    progress ||= drill.progresses \
      .left_outer_joins(:srs_progresses) \
      .where(srs_progresses: {id: nil}, burned_at: nil) \
      .order(id: :asc) \
      .first

    current_user.leitner_fresh += 1 if progress.present?
  end

  session_boxes = [[0,1,5,8],[1,2,6,9],[2,3,7,0],[3,4,8,1],[4,5,9,2],[5,6,0,3],[6,7,1,4],[7,8,2,5],[8,9,3,6],[9,0,4,7]]
  # Select cards in one of the boxes for current session
  progress ||= SrsProgress.includes(:progress) \
    .joins(:progress) \
    .merge(drill.progresses) \
    .where(learning_type: :reading_question, leitner_box: session_boxes[current_user.leitner_session]) \
    .where.not(leitner_last_reviewed_at_session: current_user.leitner_session) \
    .order(id: :asc) \
    .first.try(:progress)

  if !progress.present? && allow_recursion
    current_user.leitner_session += 1
    current_user.leitner_session %= 10
    current_user.leitner_fresh = 0

    progress = get_drill_word(drill_id, fresh, false)
  end
  current_user.save

  return progress
end

get :api_question do
  protect!

  if params[:type] == 'sentences'
    get_drill_sentence(params[:drill_id])
  else
    progress = get_drill_word(params[:drill_id], params[:fresh].present?)

    {
      sentence: [{'seq' => progress.seq, 'text' => progress.title, 'base' => progress.title}],
      english: nil,
      j: Collector.new(current_user, words: Word.where(seq: progress.seq)).to_hash
    }.to_json
  end
end
