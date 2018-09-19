require 'mojinizer'
require 'ox'

# For some reason, OX throws an error:
# Ox::ParseError (invalid format, dectype not terminated at line 516337, column 6 [parse.c:336])
# Easy way to avoid this is to remove (manually) all <!DOCTYPE>/<!ELEMENT>/<!ATTLIST> tags in header
xml = Ox.parse(File.read("../wakame_data/edrdg/kanjidic2.xml2")); nil


xml.locate('kanjidic2/character').each do |char|
  k = Kanji.new(
    title: char.locate('literal')[0].text, # literal: 1 (count of elements)
    grade: char.locate('misc/grade')[0].try(:text).try(:to_i), # misc/grade: none or 1
    jlpt: char.locate('misc/jlpt')[0].try(:text).try(:to_i), # misc/jlpt: none or 1
  )
  char.locate('dic_number/dic_ref').each do |dic_ref|
    k.heisig = dic_ref.text.to_i if dic_ref.dr_type == 'heisig'
  end
  char.locate('misc/stroke_count').each do |stroke_count|
    k.strokes ||= []
    k.strokes << stroke_count.text.to_i
## Select kanji with more than 2 different stroke_counts
# Kanji.where('array_length(strokes, 1) > 2').pluck(:title, :strokes)
## Select kanji with 7 strokes
# Kanji.where('? = ANY(strokes)', 7)
  end

  char.locate('reading_meaning/rmgroup/reading').each do |reading|
    if reading.r_type == 'ja_on'
      k.on ||= []
      k.on << reading.text
    elsif reading.r_type == 'ja_kun'
      k.kun ||= []
      k.kun << reading.text
    end
  end

  char.locate('reading_meaning/rmgroup/meaning').each do |meaning|
    next if meaning.attributes.has_key?(:m_lang) # english meanings doesn't have any 'm_lang' attributes
    k.english ||= []
    k.english << meaning.text
  end

  char.locate('reading_meaning/nanori').each do |nanori|
    k.nanori ||= []
    k.nanori << nanori.text
  end

  k.save
end; nil


j = JSON.parse(File.read('../wakame_data/jlpt_kanji.json'))
[1,2,3,4,5].each do |i|
  j["N#{i}"].each do |t|
    k = Kanji.find_by(title: t)
    k.update_attribute(:jlptn, i)
  end
end; nil
