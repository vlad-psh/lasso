require "open-uri"
require "uri"

def download(url, path)
  File.open(path, "w") do |f|
    IO.copy_stream(open(url), f)
  end
end


offset = 0
while (cc = Card.words.order(:id).limit(100).offset(offset)).length > 0
  cc.each do |c|
    puts "#{c.id} #{c.title}"
    download("http://speech.fc:53000/?v=VW%20Show&t=#{URI::encode(c.title)}", "public/audio/#{c.id}.mp3")
    c.detailsb['sentences'].each_with_index do |sentence, i|
      download("http://speech.fc:53000/?v=VW%20Show&t=#{URI::encode(sentence['ja'])}", "public/audio/s#{c.id}_#{i}.mp3")
    end if c.detailsb['sentences']
  end
  offset += 100
end; nil

