# JLPT data was taken from jlearn.net website and
# parsed into jlpt_kanji.json file

j = JSON.parse(File.read('data/jlpt_kanji.json'))
missed = []
j.each do |jlpt_level,kanjis|
  lvl = jlpt_level[1].to_i # Get number from JLPT level (eg: "N1")
  kanjis.each do |k|
    c = Card.kanjis.find_by(title: k)
    if c.present?
      c.detailsb['jlpt'] = lvl
      c.save
    else
      missed << k
    end
  end
end; nil

