paths api_sentence: '/api/sentence',
    api_question_drill: '/api/question/drill',
    word_details: '/api/word', # params: seq
    api_word_autocomplete: '/api/word/autocomplete',
    api_learn:   '/api/word/learn',
    api_burn:    '/api/word/burn',
    api_comment: '/api/comment',
    drill_add_word: '/drill/word',
    kanji_readings: '/api/kanji_readings',
    activity: '/api/activity/:category/:seconds'

get :word_details do
  protect!
  return Collector.new(current_user, words: Word.where(seq: params[:seq])).to_json
end

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
            gloss: i.en[0]['gloss'][0],
            href: path_to(:word).with(i.seq)
        }
  }
  return ww.to_json
end

def find_or_init_progress(p)
  kind = p[:kind].to_sym

  return case p[:kind].to_sym
    when :w
      Progress.find_or_initialize_by(seq: p[:id], title: p[:title], user: current_user)
    when :k
      i = Progress.find_or_initialize_by(kanji_id: p[:id], user: current_user)
      i.title = p[:title]
      i
    when :r
      i = Progress.find_or_initialize_by(wk_radical_id: p[:id], user: current_user)
      i.title = p[:title]
      i
    else
      raise ArgumentError.new('Incorrect "kind" value')
    end
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
  progress.burn!

  return progress.api_json
end

post :api_comment do
  protect!

  comment = params[:comment].strip

  if params[:seq].present?
    wd = WordDetail.find_or_create_by(user: current_user, seq: params[:seq])
    wd.update_attribute(:comment, comment.present? ? comment : nil)

    return wd.comment
  elsif params[:kanji].present?
    kanji = Kanji.find_by(title: params[:kanji])
    halt(404, "Kanji not found") if kanji.blank?
    progress = find_or_init_progress({kind: :k, id: kanji.id})
    progress.update(comment: comment.present? ? comment : nil)

    return progress.api_json
  end
end

post :drill_add_word do
  protect!

  drill = Drill.find_by(id: params[:drill_id], user: current_user)
  halt(404, "Drill list not found") if drill.blank?

  word_title = params[:title] || Word.find_by(seq: params[:id]).krebs.first
  progress = find_or_init_progress({kind: :w, id: params[:id], title: word_title})
  progress.flagged = true
  progress.save

  drill.progresses << progress

  return 'ok'
end

get :api_question_drill do
  protect!
  drill = Drill.find(params[:id])

  progress = drill.progresses.left_outer_joins(:srs_progresses).where(srs_progresses: {id: nil}).first ||
          SrsProgress.includes(:progress).joins(:progress).merge( drill.progresses ).where(learning_type: :reading_question).order('drill_order ASC NULLS FIRST').first.progress

  return {
      sentence: [{'seq' => progress.seq, 'text' => progress.title, 'base' => progress.title}],
      english: nil,
      j: Collector.new(current_user, words: Word.where(seq: progress.seq)).to_hash
    }.to_json
end

post :kanji_readings do
  protect!

  kanji = Kanji.find_by(title: params[:kanji])
  halt(404, "Kanji not found" + params.inspect) if kanji.blank?

  result = {}
  kanji.on.each do |on|
    result[on] = Kanji.joins(:kanji_readings).merge(
      KanjiReading.where(reading: on, kind: :on)
    ).where.not(grade: nil).distinct.sort{|a,b| a.grade <=> b.grade}.map{|i| [i.title, i.grade]}
  end if kanji.on.present?

  kanji.kun.map{|i| i.gsub(/\..*/, '')}.uniq.each do |kun|
    kun = kun.gsub(/\..*/, '') # Drop okurigana
    result[kun] = Kanji.joins(:kanji_readings).merge(
      KanjiReading.where('reading SIMILAR TO ?', kun + '(.%)?').where(kind: :kun)
    ).where.not(grade: nil).distinct.sort{|a,b| a.grade <=> b.grade}.map{|i| [i.title, i.grade]}
  end if kanji.kun.present?

  return result.to_json
end

get :activity do
  protect!

  halt(405, "Unknown category") unless %w(search srs kanji kokugo onomat).include?(params[:category])
  a = Activity.find_or_initialize_by(user: current_user, category: params[:category], date: custom_today)
  a.seconds += params[:seconds].to_i
  a.save

  a.seconds.to_s
end
