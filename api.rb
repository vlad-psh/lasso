get :api_word do
  protect!

  word = Word.includes(:short_words, :long_words, :wk_words, :word_titles).where(seq: params[:id]).with_progresses(current_user)[0]
  @title = word.word_titles.first.title
  word_details = word.word_details.where(user: current_user).take
  sentences = Sentence.where(structure: nil).where('japanese ~ ?', word.krebs.join('|')) # possible sentences

  kanji = word.kanji.present? ? Hash[ Kanji.where(title: word.kanji.split('')).map {|k| [k.title, k]} ] : {}

  found_progresses = word.user_progresses ? Hash[*word.user_progresses.map{|i| [i.title, i]}.flatten] : {}
  sorted_word_titles = word.word_titles.sort{|a,b| a.id <=> b.id}.map{|t| {title: t.title, is_common: t.is_common}}
  progresses = {}
  sorted_word_titles.each do |t|
    progresses[t[:title]] = found_progresses[t[:title]] || {}
  end

  return {
    word: word,
    krebs: sorted_word_titles,
    progresses: progresses,
    shortWords: word.short_words.map{|i| {seq: i.seq, title: i.krebs[0], href: path_to(:word).with(i.seq)}},
    longWords:  word.long_words.map{|i| {seq: i.seq, title: i.krebs[0], href: path_to(:word).with(i.seq)}},
    rawSentences: sentences.map{|i| {jp: i.japanese, en: i.english, href: path_to(:sentence).with(i.id)}},
    sentences: word.all_sentences.map{|i| {jp: i.japanese, en: i.english, href: path_to(:sentence).with(i.id)}},
    comment: word_details.try(:comment) || '',
    cards: word.wk_words.sort{|a,b| a.level <=> b.level}.map{|c|
      {
        title: c.title,
        level: c.level,
        readings: c.details['readings'].join(', '),
        en:    c.details['en'].join(', '),
        pos:   c.details['pos'],
        mexp:  c.details['mexp'],
        rexp:  c.details['rexp'],
        href:  path_to(:wk_word).with(c.id)
      }
    },
    kanji: kanji,
    paths: {
      connect: path_to(:word_connect),
      learn:   path_to(:word_learn),
      burn:    path_to(:word_burn),
      flag:    path_to(:word_flag),
      comment: path_to(:word_set_comment).with(word.seq),
      autocomplete: path_to(:autocomplete_word)
    }
  }.to_json
end

get :api_sentence do
  progress = Progress.words.expired.where(user: current_user).order('RANDOM()').first
  main_word = progress.word
  main_word.sentences.where.not(structure: nil).order('RANDOM()').each do |sentence|
    all_words_learned = sentence.words.with_progresses(current_user).map {|w| w.user_progresses.try(:first).try(:learned_at).present?}.index(false) == nil
    if all_words_learned
      @sentence = sentence
      break
    end
  end
#  @sentence = Sentence.where.not(structure: nil).order('RANDOM()').first

  if @sentence.blank?
    # Compose (without saving) sentence with only one word
    return {
      sentence: [{'text' => progress.title, 'seq' => progress.seq}],
      english: nil
    }.to_json
  else
    return {
      sentence: @sentence.structure,
      english: @sentence.english
    }.to_json
  end
end
