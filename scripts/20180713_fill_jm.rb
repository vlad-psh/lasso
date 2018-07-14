require 'ox'
xml = Ox.parse(File.read("../JMdict")); nil


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
  return result
end

xml.locate('JMdict/entry').each do |entry| # проходим по каждой записи
  element_added = false

  entry.locate('k_ele').each do |k_ele|
    ph = pri_hash(k_ele.locate('ke_pri').map{|i|i.text})
    if ph.length > 0
      je = JmElement.new()
      ph.each {|k,v| je[k] = v}
      je.ent_seq = entry.ent_seq.text.to_i
      je.is_kanji = true
      je.title = k_ele.keb.text
      je.save
      element_added = true
    end
  end

  entry.locate('r_ele').each do |r_ele|
    ph = pri_hash(r_ele.locate('re_pri').map{|i|i.text})
    if ph.length > 0
      je = JmElement.new()
      ph.each {|k,v| je[k] = v}
      je.ent_seq = entry.ent_seq.text.to_i
      je.is_kanji = false
      je.title = r_ele.reb.text
      je.save
      element_added = true
    end
  end

  if element_added
    meaning_rus = []
    meaning_eng = []
    pos = []
    entry.locate('sense').each do |sense|
      sense_eng = []
      sense_rus = []
      sense.locate('gloss').each do |gloss|
        if gloss.attributes[:"xml:lang"] == nil # english
          sense_eng << gloss.text
        elsif gloss.attributes[:"xml:lang"] == "rus"
          sense_rus << gloss.text
        end
      end
      meaning_eng << sense_eng if sense_eng.length > 0
      meaning_rus << sense_rus if sense_rus.length > 0
      pos.push(*sense.locate('pos').map{|i|i.text})
    end

    JmMeaning.create(
      ent_seq: entry.ent_seq.text.to_i,
      en: meaning_eng,
      ru: meaning_rus,
      pos: pos
    )
  end

end; nil


offset = 0
while (jmes = JmElement.where.not(nf: nil).order(:ent_seq).offset(offset).limit(100)).length > 0
  jmes.each do |jme|
    jmm = JmMeaning.find_by(ent_seq: jme.ent_seq)
    if (jmm.nf == nil || jmm.nf > jme.nf)
      jmm.nf = jme.nf
      jmm.save
    end
  end
  offset += 100
end; nil

