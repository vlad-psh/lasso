require "open-uri"
require "uri"

def download(url, path)
  begin
    File.open(path, "w") do |f|
      IO.copy_stream(open(url), f)
    end
    return true
  rescue
    puts "Got an error... sleeping 1 second"
    sleep 1
    return false
  end
end

def startfrom(startid)
  offset = 0
  while (cc = Card.words.where(Card.arel_table[:id].gt(startid)).order(:id).limit(100).offset(offset)).length > 0
    cc.each do |c|
      puts "#{c.id} #{c.title}"
      until download("http://speech.fc:53000/?v=VW%20Show&t=#{URI::encode(c.title)}", "public/audio/#{c.id}.mp3") do true end
      c.detailsb['sentences'].each_with_index do |sentence, i|
        until download("http://speech.fc:53000/?v=VW%20Show&t=#{URI::encode(sentence['ja'])}", "public/audio/s#{c.id}_#{i}.mp3") do true end
      end if c.detailsb['sentences']
    end
    offset += 100
  end
end

startfrom(5616)

