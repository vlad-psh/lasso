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

post :api_word_flag do
  protect!

  progress = Progress.find_or_initialize_by(
        seq: params[:seq],
        title: params[:kreb],
        user: current_user,
        kind: :w)
  progress.flagged_at = DateTime.now
  progress.save

  return progress.api_json
end

post :api_word_learn do
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
  progress.scheduled = Date.today
  progress.transition = Date.today
  progress.save

  Action.create(user: current_user, progress: progress, action_type: :learned)

  stats = Statistic.find_or_initialize_by(user: current_user, date: Date.today)
  stats.learned['w'] += 1
  stats.save

  return progress.api_json
end

post :api_word_burn do
  protect!

  progress = Progress.find_by(id: params[:progress_id], user: current_user)
  progress.answer!(:burn)

  return progress.api_json
end

post :api_word_comment do
  protect!

  wd = WordDetail.find_or_create_by(user: current_user, seq: params[:seq])
  wd.update_attribute(:comment, params[:comment].strip.present? ? params[:comment] : nil)

  return 'ok'
end

post :api_word_connect do
  protect!

  long = Word.find_by(seq: params[:long])
  short = Word.find_by(seq: params[:short])
  long.short_words << short

  return 'ok'
end

delete :api_word_connect do
  protect!

  long = Word.find_by(seq: params[:long])
  short = Word.find_by(seq: params[:short])
  long.short_words.delete(short)

  return 'ok'
end

post :drill_add_word do
  protect!

  progress = Progress.find_or_initialize_by(
        seq: params[:seq],
        title: params[:kreb],
        user: current_user,
        kind: :w)
  progress.save

  drill = Drill.find_or_create_by(
        title: params[:drillTitle].strip,
        user: current_user
  )
  drill.progresses << progress

  return 'ok'
end

get :api_drill do
  protect!
  return Collector.new(current_user, words: Word.joins(:progresses).merge( Drill.last.progresses )).to_json
end
