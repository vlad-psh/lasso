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

  learning_type = params[:type] =~ /kanji/ ? :kanji_question : :reading_question

  params[:answers].each do |i,a|
    next if a['answer'] == 'burned' # why??
    drill = Drill.find_by(user: current_user, id: params[:drill_id]) if params[:drill_id]
    a['progress'].answer!(a['answer'], drill: drill || nil, learning_type: learning_type)
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

def get_drill_word(drill_id, learning_type = :reading_question, fresh = false, allow_recursion = true)
  drill = Drill.find(drill_id)

  # Try to find failed cards
  progress ||= drill.progresses.srs_failed(learning_type, drill.leitner_session).order('random()').first

  if drill.leitner_fresh < 5 && fresh && !progress.present?
    progress ||= drill.progresses.srs_new(learning_type).order('random()').first
    progress ||= drill.progresses.srs_nil(learning_type).order('random()').first

    word_type ||= :new if progress.present?
# TODO: if we just reload the page (without answering), 'fresh' counter will still be incremented
    drill.update(leitner_fresh: drill.leitner_fresh + 1) if progress.present?
  end

  # Select cards in one of the boxes for current session
  progress ||= drill.progresses.srs_expired(learning_type, drill.leitner_session).order('random()').first
  word_type ||= :review if progress.present?

  if !progress.present? && allow_recursion
    drill.update(leitner_session: (drill.leitner_session + 1) % 10, leitner_fresh: 0)
    progress = get_drill_word(drill_id, learning_type, fresh, false)
  else
    sp = progress.srs_progresses.first
    puts "========== #{DateTime.now.strftime('%H:%M:%S')} Session #{drill.leitner_session} #{Progress::LEITNER_BOXES[drill.leitner_session]} card:'#{word_type}' box:#{sp.leitner_box rescue 'n/a'} combo:#{sp.leitner_combo rescue 'n/a'}/4 #{progress.title}"
  end

  return progress
end

get :api_question do
  protect!

# TODO: use logic similar to below to select sentences
  return get_drill_sentence(params[:drill_id]) if params[:type] == 'sentences'

  learning_type = %w(sentence-kanji).include?(params[:type]) ? :kanji_question : :reading_question

  progress = get_drill_word(params[:drill_id], learning_type, params[:fresh].present?)

  if params[:type] == 'sentence-kanji'
    sentence = progress.word.sentences.where(drill_id: params[:drill_id]).first
# TODO: look up SentenceReviews table and take ones who weren't reviewed at all or have not been reviewed recently
#        .left_outer_joins(:sentence_reviews).order(
    sentence.swap_kanji_yomi
  end

  if sentence.present?
    {
      sentence_id: sentence.id,
      sentence: sentence.structure,
      english: sentence.english,
      j: Collector.new(current_user, words: Word.where(seq: sentence.words.map(&:seq))).to_hash
    }.to_json
  else
    {
      sentence: [{'seq' => progress.seq, 'text' => progress.title, 'base' => progress.title}],
      english: nil,
      j: Collector.new(current_user, words: Word.where(seq: progress.seq)).to_hash
    }.to_json
  end
end
