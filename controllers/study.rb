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
    next unless a['answer'].present? # some words can be left unanswered (only 'main' word is necessary)
    a['progress'] = Progress.find_or_initialize_by(seq: a['seq'], title: a['base'], user: current_user)
  end

  learning_type = params[:type] =~ /kanji/ ? :kanji_question : :reading_question

  params[:answers].each do |i,a|
    next if a['answer'] == 'burned' # why??
    next unless a['answer'].present?
    drill = Drill.find_by(user: current_user, id: params[:drill_id]) if params[:drill_id]
    a['progress'].answer!(a['answer'], drill: drill || nil, learning_type: learning_type)
  end

  if params[:sentence_id].present?
    review = SentenceReview.find_or_initialize_by(sentence_id: params[:sentence_id], user: current_user)
    review.update(reviewed_at: DateTime.now)
  end

  return 'ok'
end

def get_drill_word(drill, init_session, learning_type = :reading_question, fresh = false)
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

  if !progress.present?
    drill.update(leitner_session: (drill.leitner_session + 1) % 10, leitner_fresh: 0)
    progress = get_drill_word(drill, init_session, learning_type, fresh) unless drill.leitner_session == init_session
  else
    sp = progress.srs_progresses.first
    puts "========== #{DateTime.now.strftime('%H:%M:%S')} Session #{drill.leitner_session} #{Progress::LEITNER_BOXES[drill.leitner_session]} card:'#{word_type}' box:#{sp.leitner_box rescue 'n/a'} combo:#{sp.leitner_combo rescue 'n/a'}/4 #{progress.title}"
  end

  return progress
end

get :api_question do
  protect!

  # params[:type] = nil | sentence | sentence-kanji
  learning_type = %w(sentence-kanji).include?(params[:type]) ? :kanji_question : :reading_question

  drill = Drill.find_by(id: params[:drill_id], user: current_user)
  progress = get_drill_word(drill, drill.leitner_session, learning_type, params[:fresh].present?)

  if params[:type] =~ /sentence/
    sentence = progress.word.sentences.where(drill_id: params[:drill_id]).first
# TODO: look up SentenceReviews table and take ones who weren't reviewed at all or have not been reviewed recently
#        .left_outer_joins(:sentence_reviews).order(
    sentence.highlight_word(progress.seq) if sentence.present?
  end

  sentence ||= progress.to_sentence
  sentence.swap_kanji_yomi if learning_type == :kanji_question

  return sentence.study_hash(current_user).to_json
end
