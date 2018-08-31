require 'mojinizer'

File.readlines('../wakame_data/edrdg/kanjidic_utf8').each do |line|
  words = line.split

  # skip first record with copyright info
  next if words[0] == '#'

  kanji = words.shift
  jis_code = words.shift

  values = {}
  while !words[0].contains_japanese?
    # leading capital letters are remembered as 'k'
    # everything else is 'v'
    w = words.shift
    m = w.match(/(?<k>[A-Z]*)(?<v>.*)/)
    throw StandardError.new("Unable to parse #{w}") unless m

    if %w(DA O Q S V W XDR XH XJ XN Y ZBP ZPP ZRP ZSP).include?(m[:k])
      # those keys can have multiple values (array)
      values[m[:k]] ||= []
      values[m[:k]] << m[:v]
    else
      # single value keys
      throw StandardError.new("Key is already defined: #{m[:k]} in line: #{line}") if values[m[:k]]
      values[m[:k]] = m[:v]
    end
  end

  readings = {on: [], kun: [], nanori: [], english: []}
  while words[0].contains_japanese?
    w = words.shift
    readings[ w[0].katakana? ? :on : :kun ] << w
  end

  while words[0][0] == 'T' # T1 T2 etc
    # next are nanori readings
    words.shift
    while words[0].contains_japanese?
      readings[:nanori] << words.shift
    end
  end

  words = words.join(' ').strip
  throw StandardError.new("Unexpected format of english words in <<#{line}>>") if words[0] != '{' || words[-1] != '}'
  words = words[1..-2].split('} {')
  while words.length > 0
    readings[:english] << words.shift
  end

  puts "#{kanji} #{readings.inspect}"

  _k = Kanji.create(
        title: kanji,
        jlpt: values['J'].try(:to_i),
        grade: values['G'].try(:to_i),
        heisig: values['L'].try(:to_i)
# TODO: strokes (it is not a simple number, but array of numbers)
  )

  [:on, :kun, :nanori, :english].each do |k|
    readings[k].each do |v|
      KanjiProperty.create(
        kanji: _k,
        title: v,
        kind: k
      )
    end
  end
end; nil


j = JSON.parse(File.read('../wakame_data/jlpt_kanji.json'))
[1,2,3,4,5].each do |i|
  j["N#{i}"].each do |t|
    k = Kanji.find_by(title: t)
    k.update_attribute(:jlptn, i) 
  end
end; nil


Card.kanjis.select(:id, :title, :level).each do |c|
  k = Kanji.find_by(title: c.title)
  next unless k # 々 is not included in kanjidic
  k.update_attributes({
    card_id: c.id,
    wk: c.level
  })
end; nil

