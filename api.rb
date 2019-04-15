PROGRESS_PROPERTIES = [:id, :deck, :learned_at, :burned_at, :flagged]

def word_json(seq, options = {})
  word = Word.includes(:short_words, :long_words, :wk_words, :word_titles).where(seq: seq).with_progresses(current_user)[0]
  result = word.serializable_hash(only: [:seq, :en, :ru, :jlptn, :nf])

  @title = word.word_titles.first.title
  result[:comment] = word.word_details.where(user: current_user).take.try(:comment) || ''

  progresses = word.user_progresses ? Hash[*word.user_progresses.map{|i| [i.title, i]}.flatten] : {}
  result[:krebs] = word.word_titles.sort{|a,b| a.id <=> b.id}.map do |t|
    {
      title: t.title,
      is_common: t.is_common,
      progress: progresses[t.title].try(:serializable_hash, only: PROGRESS_PROPERTIES) || {}
    }
  end

  result[:sentences] = word.all_sentences.map{|i| {jp: i.japanese, en: i.english, href: path_to(:sentence).with(i.id)}}
  rawSentences = Sentence.where(structure: nil).where('japanese ~ ?', word.krebs.join('|')) # possible sentences
  result[:rawSentences] = rawSentences.map{|i| {jp: i.japanese, en: i.english, href: path_to(:sentence).with(i.id)}}

  kanji = word.kanji.present? ? Hash[ Kanji.where(title: word.kanji.split('')).map {|k| [k.title, k]} ] : {}

  return result.merge({
    shortWords: word.short_words.map{|i| {seq: i.seq, title: i.krebs[0], href: path_to(:word).with(i.seq)}},
    longWords:  word.long_words.map{|i| {seq: i.seq, title: i.krebs[0], href: path_to(:word).with(i.seq)}},
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
  }).to_json
end

get :api_word do
  protect!

  return word_json(params[:id])
end

get :api_sentence do
  progress = Progress.words.expired.where(user: current_user).order('RANDOM()').first
  main_word = progress.word
  main_word.sentences.where.not(structure: nil).order('RANDOM()').each do |sentence|
    unless sentence.words.with_progresses(current_user).map {|w| w.user_progresses.try(:first).try(:learned_at).present?}.include?(false)
      # If all words in sentence are learned
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

post :word_flag do
  protect!

  progress = Progress.find_or_initialize_by(
        seq: params[:seq],
        title: params[:kreb],
        user: current_user,
        kind: :w)
  progress.flagged = true
  progress.save

  return progress.to_json(only: PROGRESS_PROPERTIES)
end

post :word_learn do
  protect!

  progress = Progress.find_or_initialize_by(
        seq: params[:seq],
        title: params[:kreb],
        user: current_user,
        kind: :w)
  throw StandardError.new("Already learned") if progress.learned_at.present?

  unless progress.unlocked
    progress.unlocked = true
    progress.unlocked_at = DateTime.now
  end

  progress.learned_at = DateTime.now
  progress.deck = 0
  progress.save

  Action.create(user: current_user, progress: progress, action_type: :learned)

  stats = Statistic.find_or_initialize_by(user: current_user, date: Date.today)
  stats.learned['w'] += 1
  stats.save

  return progress.to_json(only: PROGRESS_PROPERTIES)
end

post :word_burn do
  protect!

  progress = Progress.find_by(id: params[:progress_id], user: current_user)
  progress.update_attribute(:burned_at, DateTime.now)

  Action.create(user: current_user, progress: progress, action_type: :burn)

  return progress.to_json(only: PROGRESS_PROPERTIES)
end
