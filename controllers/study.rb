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
    drill = Drill.find_by(user: current_user, id: params[:drill_id]) if params[:drill_id]
    a['progress'].answer!(a['answer'], drill: drill || nil)
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
    .merge(drill.progresses.where(burned_at: nil)) \
    .where(learning_type: :reading_question, leitner_box: nil) \
    .where.not(leitner_last_reviewed_at_session: [drill.leitner_session, nil, 10]) \
    .order('random()') \
    .first.try(:progress)
  word_type = :failed if progress.present?

  if drill.leitner_fresh < 5 && fresh && !progress.present?
    progress ||= SrsProgress.includes(:progress) \
      .joins(:progress) \
      .merge(drill.progresses.where(burned_at: nil)) \
      .where(learning_type: :reading_question, leitner_last_reviewed_at_session: nil) \
      .order('random()') \
      .first.try(:progress)
    # Next try to select cards without any SrsProgress records
    progress ||= drill.progresses.where(burned_at: nil) \
      .left_outer_joins(:srs_progresses) \
      .where(srs_progresses: {id: nil}, burned_at: nil) \
      .order('random()') \
      .first

    word_type ||= :new if progress.present?
# TODO: if we just reload the page (without answering), 'fresh' counter will still be incremented
    drill.update(leitner_fresh: drill.leitner_fresh + 1) if progress.present?
  end

  session_boxes = [[0,2,5,9],[1,3,6,0],[2,4,7,1],[3,5,8,2],[4,6,9,3],[5,7,0,4],[6,8,1,5],[7,9,2,6],[8,0,3,7],[9,1,4,8]]
  session_boxes = [[0,1,5,8],[1,2,6,9],[2,3,7,0],[3,4,8,1],[4,5,9,2],[5,6,0,3],[6,7,1,4],[7,8,2,5],[8,9,3,6],[9,0,4,7]]
  # Select cards in one of the boxes for current session
  progress ||= SrsProgress.includes(:progress) \
    .joins(:progress) \
    .merge(drill.progresses.where(burned_at: nil)) \
    .where(learning_type: :reading_question, leitner_box: session_boxes[drill.leitner_session]) \
    .where.not(leitner_last_reviewed_at_session: drill.leitner_session) \
    .where(SrsProgress.arel_table[:leitner_combo].lt(5)) \
    .order('random()') \
    .first.try(:progress)
  word_type ||= :review if progress.present?

  if !progress.present? && allow_recursion
    drill.update(leitner_session: (drill.leitner_session + 1) % 10, leitner_fresh: 0)
    progress = get_drill_word(drill_id, fresh, false)
  else
    sp = progress.srs_progresses.first
    puts "========== Session #{drill.leitner_session} #{session_boxes[drill.leitner_session]} card:'#{word_type}' box:#{sp.leitner_box rescue 'n/a'} combo:#{sp.leitner_combo rescue 'n/a'}/4"
  end

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
