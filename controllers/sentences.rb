require 'aws-sdk-polly'

# paths with indent: already in use with new frontent
paths \
    sentences: '/api/sentences',
    sentence:  '/api/sentence/:id',
    sentence_audio: '/api/sentence/:id/audio'

get :sentence do
  protect!
  # TODO: smarter selection of expired words
  progress = Progress.words.expired.where(user: current_user).order('RANDOM()').first
  main_word = progress.word
  main_word.sentences.where.not(structure: nil).order('RANDOM()').each do |sentence|
    unless sentence.words.as_for(current_user).map {|w| w.progresses.try(:first).try(:learned_at).present?}.include?(false)
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

delete :sentence do
  protect!

  s = Sentence.find(params[:id])
  s.destroy

  return 'ok'
end

post :sentences do
  protect!

  drill = Drill.find_by(user: current_user, id: params['drill_id'])

  s = Sentence.new({
    japanese: params['japanese'],
    english: params['english'],
#    russian: params[''],
    structure: params['structure'],
    drill: drill,
    user: current_user
  })
  s.save

  s.words = Word.where(seq: s.structure.map{|i| i['seq']}.compact.uniq)

  return 'OK'
end

get :sentence_audio do
  protect!

  sentence = Sentence.find_by(id: params[:id], user: current_user)
  halt(404, "Sentence not found") unless sentence.present?

  polly_client = Aws::Polly::Client.new(
    region: $config['aws_region'],
    credentials: Aws::Credentials.new($config['aws_access_key'], $config['aws_secret_key'])
  )

  polly_resp = polly_client.synthesize_speech({
    output_format: "mp3",
    sample_rate: "22050",
    text: sentence.japanese,
    text_type: "text",
    voice_id: "Mizuki",
  })

  content_type 'audio/mpeg'
  polly_resp.audio_stream.read
end
