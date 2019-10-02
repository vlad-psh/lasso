paths api_sentence: '/api/sentence',
    api_question_drill: '/api/question/drill',
    api_word_autocomplete: '/api/word/autocomplete',
    # POST:
    api_learn:   '/api/word/learn',
    api_burn:    '/api/word/burn',
    api_flag:    '/api/word/flag',
    api_word_comment: '/api/word/comment',
    api_add_word_to_drill: '/api/drill/add_word',
    drill_add_word: '/drill/word'


get :api_sentence do
  protect!
  # TODO: smarter selection of expired words
  progress = Progress.words.expired.where(user: current_user).order('RANDOM()').first
  main_word = progress.word
  main_word.sentences.where.not(structure: nil).order('RANDOM()').each do |sentence|
    unless sentence.words.with_progresses(current_user).map {|w| w.user_progresses.try(:first).try(:learned_at).present?}.include?(false)
      # If all words in sentence are learned
      @sentence = sentence
      break
    end
  end

  if @sentence.blank?
    # Compose (without saving) sentence with only one word
    return {
      sentence: [{'seq' => progress.seq, 'text' => progress.title, 'base' => progress.title}],
      english: nil,
      j: Collector.new(current_user, words: Word.where(seq: progress.seq)).to_hash
    }.to_json
  else
    return {
      sentence: @sentence.structure,
      english: @sentence.english,
      j: Collector.new(current_user, words: Word.where(seq: @sentence.words.map(&:seq))).to_hash
    }.to_json
  end
end

get :api_word_autocomplete do
  protect!

  ww = Word.where(seq: WordTitle.where(title: params['term']).pluck(:seq)).map{|i|
        {
            id: i.seq,
            value: "#{i.krebs[0]}: #{i.en[0]['gloss'][0]}",
            title: i.krebs[0],
            href: path_to(:word).with(i.seq)
        }
  }
  return ww.to_json
end

def find_or_init_progress(p)
  kind = p[:kind].to_sym

  return case p[:kind].to_sym
    when :w
      Progress.find_or_initialize_by(seq: p[:id], title: p[:title], user: current_user, kind: :w)
    when :k
      i = Progress.find_or_initialize_by(kanji_id: p[:id], kind: :k, user: current_user)
      i.title = p[:title]
      i
    when :r
      i = Progress.find_or_initialize_by(wk_radical_id: p[:id], kind: :r, user: current_user)
      i.title = p[:title]
      i
    else
      raise ArgumentError.new('Incorrect "kind" value')
    end
end

post :api_flag do
  protect!

  progress = find_or_init_progress(params)
  progress.flagged_at = DateTime.now
  progress.save

  return progress.api_json
end

post :api_learn do
  protect!

  progress = find_or_init_progress(params)
  progress.learn!

  return progress.api_json
end

post :api_burn do
  protect!

  progress = find_or_init_progress(params)
  progress.answer!(:burn)

  return progress.api_json
end

post :api_word_comment do
  protect!

  wd = WordDetail.find_or_create_by(user: current_user, seq: params[:seq])
  wd.update_attribute(:comment, params[:comment].strip.present? ? params[:comment] : nil)

  return 'ok'
end

post :drill_add_word do
  protect!

  progress = find_or_init_progress(params)
  progress.save

  drill = Drill.find_by(id: params[:drill_id], user: current_user)
  drill.progresses << progress

  return 'ok'
end

get :api_question_drill do
  protect!
  drill = Drill.find(params[:id])
  progress = drill.progresses.where(user: current_user, reviewed_at: nil).sample || drill.progresses.where(user: current_user).order(reviewed_at: :asc).first
  return {
      sentence: [{'seq' => progress.seq, 'text' => progress.title, 'base' => progress.title}],
      english: nil,
      j: Collector.new(current_user, words: Word.where(seq: progress.seq)).to_hash
    }.to_json
end

post :api_add_word_to_drill do
  protect!

  drill = Drill.find_by(id: params[:drill_id], user: current_user)
  w = Word.find_by(seq: params[:seq])
  progress = find_or_init_progress({kind: :w, id: w.seq, title: w.krebs.first})
  drill.progresses << progress

  return 'ok'
end
