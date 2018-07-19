require 'ox'
xml = Ox.parse(File.read("../wakame_data/edrdg/JMdict")); nil


def pri_hash(arr)
  result = {}
  arr.each do |pri|
    if (pri =~ /^ichi/)
      result[:ichi] = pri.gsub(/ichi/, '').to_i
    elsif (pri =~ /^news/)
      result[:news] = pri.gsub(/news/, '').to_i
    elsif (pri =~ /^spec/)
      result[:spec] = pri.gsub(/spec/, '').to_i
    elsif (pri =~ /^gai/)
      result[:gai]  = pri.gsub(/gai/,  '').to_i
    elsif (pri =~ /^nf/)
      result[:nf]   = pri.gsub(/nf/,   '').to_i
    end
  end
  return result.keys.length > 0 ? result : nil
end

xml.locate('JMdict/entry').each do |entry| # проходим по каждой записи
  element_added = false

  word = Word.new()
  word.seq = entry.ent_seq.text.to_i

  entry.locate('k_ele').each do |k_ele|
    WordTitle.create({seq: word.seq, title: k_ele.keb.text})

    ph = pri_hash(k_ele.locate('ke_pri').map{|i|i.text})

    word.kele ||= []
    _k_ele = {keb: k_ele.keb.text}
    _k_ele[:pri] = ph if ph
    word.kele << _k_ele

    # Add nf level with lowest number
    word.nf = ph[:nf] if ph.try(:[], :nf) && (word.nf.blank? || word.nf > ph[:nf])
  end


  entry.locate('r_ele').each do |r_ele|
    WordTitle.create({seq: word.seq, title: r_ele.reb.text})

    ph = pri_hash(r_ele.locate('re_pri').map{|i|i.text})

    word.rele ||= []
    _r_ele = {reb: r_ele.reb.text}
    _r_ele[:pri] = ph if ph
    word.rele << _r_ele

    # Add nf level with lowest number
    word.nf = ph[:nf] if ph.try(:[], :nf) && (word.nf.blank? || word.nf > ph[:nf])
  end


  entry.locate('sense').each do |sense|
    _sense = {gloss: []}
    _sense_lang = ''

    sense.locate('gloss').each do |gloss|
      if gloss.attributes[:"xml:lang"] == nil # english
        _sense[:gloss] << gloss.text
        _sense_lang = 'en'
      elsif gloss.attributes[:"xml:lang"] == "rus"
        _sense[:gloss] << gloss.text
        _sense_lang = 'ru'
      end
      poses = sense.locate('pos').map{|i|i.text}
      _sense[:pos] = poses if poses.length > 0
    end

    if _sense_lang == 'ru'
      word.ru ||= []
      word.ru << _sense
    elsif _sense_lang == 'en'
      word.en ||= []
      word.en << _sense
    end
  end

  kanjis = []
  # It still uses SYMBOL (:keb) as key because it has not saved yet
  word.kele.map{|i| i[:keb]}.join('').split('').each do |i|
    kanjis << i if i.kanji?
  end if word.kele
  kanjis.uniq!
  word.kanji = kanjis.join('') if kanjis.length > 0

  word.save
end; nil

