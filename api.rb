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
      english: nil,
      words: {progress.seq => word_json(progress.seq)}
    }.to_json
  else
    return {
      sentence: @sentence.structure,
      english: @sentence.english,
      words: Hash[*@sentence.words.map{|i| [i.seq, word_json(i.seq)]}.flatten]
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

  return progress.to_json(only: Progress.api_props)
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

  return progress.to_json(only: Progress.api_props)
end

post :word_burn do
  protect!

  progress = Progress.find_by(id: params[:progress_id], user: current_user)
  progress.update_attribute(:burned_at, DateTime.now)

  Action.create(user: current_user, progress: progress, action_type: :burn)

  return progress.to_json(only: Progress.api_props)
end
