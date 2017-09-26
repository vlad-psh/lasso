require './app.rb'

kanjidic = {}
f = File.open("data/kanjidic", encoding: 'euc-jp'); nil
f.each_line do |line|
  l = line.encode('utf-8')
  m = l.match(/^(?<kanji>[^ ]*) .*/)
  next unless m
  k = m[:kanji]

  m = l.match(/.* G(?<grade>[0-9]*) .*/)
  grade = m ? m[:grade].to_i : nil

  m = l.match(/.* F(?<freq>[0-9]*) .*/)
  freq = m ? m[:freq].to_i : nil

  kanjidic[k] = {
    grade: grade,
    freq: freq
  }
end; nil
f.close

Kanji.all.each do |k|
  if i = kanjidic[k.title]
    k.grade = i[:grade]
    k.freq = i[:freq]
    k.save
  end
end; nil

