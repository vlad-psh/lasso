require 'json'

j = JSON.parse(File.read('../jpod_wotd.json'));nil

j.each do |w|
  w['sentences'].each do |s|
    unless Sentence.find_by(japanese: s['jp'])
      Sentence.create({
        japanese: s['jp'],
        english: s['en'],
        details: {
          source: 'jpod101 wotd',
          w_jp: w['jp'],
          w_jp_audio: w['jpaudio'],
          w_en: w['en'],
          date: w['date'],
          s_reading: s['reading'],
          s_jp_audio: s['jpaudio']
        }
      })
    end
  end  
end; nil

