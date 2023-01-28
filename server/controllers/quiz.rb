paths \
  quiz: '/api/quiz',
  question: '/api/question'

get :quiz do
  protect!

  slim :study2
end

post :quiz do
  protect!

  progresses = {}
  params['answers'].each do |a|
    next unless a['answer'].present? # some words can be left unanswered (only 'main' word is necessary)
    a['progress'] = Progress.find_or_initialize_by(seq: a['seq'], title: a['base'], user: current_user)
  end

  learning_type = params['type']

  params['answers'].each do |a|
    next if a['answer'] == 'burned' # why??
    next unless a['answer'].present?
    drill = Drill.find_by(user: current_user, id: params['drill_id']) if params['drill_id']
    a['progress'].answer!(a['answer'], drill: drill || nil, learning_type: learning_type)
  end

  if params['sentence_id'].present?
    review = SentenceReview.find_or_initialize_by(sentence_id: params['sentence_id'], user: current_user)
    review.update(reviewed_at: DateTime.now)
  end

  return 'ok'
end

def get_drill_word(drill, init_session, learning_type = 'reading', fresh = true)
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
    sp = progress.srs_progresses.where(learning_type: learning_type).first
  end

  return progress
end

get :question do
  protect!

  learning_type = params[:type]
  drill = Drill.find_by(id: params[:drill_id], user: current_user)
  progress = get_drill_word(drill, drill.leitner_session, learning_type)

# TODO: подобный выбор позволяет выбрать предложения, содержащие не нужный нам KREB (допустим,
# неверный вариант написания или написание каной вместо кандзей) если мы ошиблись при создании предложения
# (выбрали неправильный base для слова) То-есть здесь нам тоже нужно проверять пару Seq/Title (как для объектов Progress)
  sentence = progress.word.sentences.where(drill_id: params[:drill_id]).first
  sentence = nil if sentence.present? && sentence.structure.detect{|i| i['base'] == progress.title}.blank?
# TODO: look up SentenceReviews table and take ones who weren't reviewed at all or have not been reviewed recently
#        .left_outer_joins(:sentence_reviews).order(
  sentence.highlight_word(progress.seq) if sentence.present?

  sentence ||= progress.to_sentence
  sentence.swap_kanji_yomi if learning_type == 'writing'

  return sentence.study_hash(current_user).to_json
end
