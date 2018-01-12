#
# I've got pitch_accents.sqlite from jglossator (software for windows)
# After that, you should dump sqlite file to txt using something like this:
#   sqlite3 pitch_accents.sqlite .dump > pitch_accents.sqlite.dump

require 'json'

pitches = {}
File.readlines('pitch_accents.sqlite.dump').each do |line|
  match = line.match(/INSERT INTO Dict VALUES\(\'(?<kanji>.*)\',\'(?<reading>.*)\',\'(?<pitch>.*)\'\);/)
  next unless match
  k = match[:kanji]
  r = match[:reading]
  p = match[:pitch]
  pitches[k] ||= {}
  pitches[k][r] ||= []
  pitches[k][r] << p
end;nil

File.open('pitch_accents.json', 'w') { |file| file.write(pitches.to_json) }
