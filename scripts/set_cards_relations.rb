Kanji.all.each do |k|
  c = Card.where(element_type: 'k', title: k.title)
  raise StandardError.new("Card not found: #{k.title}") if !c || c.empty?
  raise StandardError.new("Found more than one card: #{k.title}") if c.count > 1
  c = c.take

  k.radicals.each do |r|
    rc = Card.where(element_type: 'r').where('detailsb @> ?', {en: [r.en]}.to_json)
    raise StandardError.new("Radical card not found: #{r.title} #{r.en}") if !rc || rc.empty?
    raise StandardError.new("Found more than one card: #{r.title} #{r.en}") if rc.count > 1
    rc = rc.take
    c.relations << rc
  end

  k.words.each do |w|
    wc = Card.where(element_type: 'w', title: w.title)
    raise StandardError.new("Word card not found: #{w.title} #{w.en}") if !wc || wc.empty?
    raise StandardError.new("Found more than one card: #{w.title} #{w.en}") if wc.count != 1
    wc = wc.take
    c.relations << wc
  end
end; nil

