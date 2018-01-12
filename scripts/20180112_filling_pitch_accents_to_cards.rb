# This will assign pitch accents to cards
require 'json'

pitch = File.read('data/pitch_accents.json')

Card.words.each do |c|
  c.detailsb['pitch'] = pitch[c.title]
  c.save
end; nil



# To see words without pitches, you can see this script:
Card.words.each do |c|
  d = c.detailsb['pitch']
  if d
    puts "empty: #{c.id} #{c.title}" if d.empty?
  else
    puts "nil: #{c.id} #{c.title}"
  end
end; nil

