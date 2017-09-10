require './app.rb'
require 'json'

radicals = JSON.parse(File.read('data/radicals.json'))
radicals.each do |r|
  Radical.create(
    level: r['level'],
    title: r['radical'],
    en: r['en'],
    details: {nmne: r['nmne'], nhnt: r['nhnt']}
  )
end

kanjis = JSON.parse(File.read('data/kanji.json'))
kanjis.each do |k|
  Kanji.create(
    level: k['level'],
    title: k['kan'],
    en: k['en'],
    yomi: k['yomi'],
    details: {mmne: k['mmne'], mhnt: k['mhnt'], rmne: k['rmne'], rhnt: k['rhnt']},
    similar: k['similar']
  )
end

words = JSON.parse(File.read('data/vocabulary.json'))
words.each do |w|
  Word.create(
    level: w['level'],
    title: w['word'],
    en: w['en'],
    pos: w['pos'],
    readings: w['readings'],
    sentences: w['sentences'],
    details: {mexp: w['mexp'], rexp: w['rexp']}
  )
end


words.each do |_w|
  w = Word.find_by(title: _w['word'])
  _w['kanjis'].each do |_k|
    k = Kanji.find_by(title: _k)
    k.words << w
  end
end

errors = [] # should be blank after processing
kanjis.each do |_k|
  k = Kanji.find_by(title: _k['kan'])
  k.radicals.clear
  _k['radicals'].each do |_r|
    # we should replace dash by space in radical descriptions
    # because that's how we store them in DB
    r = Radical.find_by(en: _r.gsub(/-/, ' '))
    if r
      r.kanjis << k
    else
      errors << {k: _k['kan'], r: _r}
    end
  end
end
