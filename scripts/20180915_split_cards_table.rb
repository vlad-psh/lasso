# This script will split old 'cards' table into three tables:
# 'wk_radicals', 'wk_kanji', 'wk_words' (and regenerate all relations)

offset = 0
while (cards = Card.words.limit(100).offset(offset).order(id: :asc)).length > 0
  cards.each do |c|
    WkWord.create(
      level:   c.level,
      title:   c.title,
      details: c.detailsb,
      seq:     c.seq
    )
  end
  offset += 100
end; nil

offset = 0
while (cards = Card.kanjis.limit(100).offset(offset).order(id: :asc)).length > 0
  cards.each do |c|
    WkKanji.create(
      level:   c.level,
      title:   c.title,
      details: c.detailsb
    )
  end
  offset += 100
end; nil


offset = 0
while (cards = Card.radicals.limit(100).offset(offset).order(id: :asc)).length > 0
  cards.each do |c|
    WkRadical.create(
      level:   c.level,
      title:   c.title,
      details: c.detailsb
    )
  end
  offset += 100
end; nil


offset = 0
while (cards_relations = CardsRelation.eager_load(:card, :relation).limit(100).offset(offset).order(id: :asc)).length > 0
  cards_relations.each do |cr|
    next unless cr.relation # there are few deleted cards (words)
    # cr.card is always kanji
    k = WkKanji.find_by(title: cr.card.title)
    if cr.relation.word?
      w = WkWord.find_by(title: cr.relation.title)
      k.wk_words << w
    else # radical
      r = WkRadical.find_by(title: cr.relation.title)
      k.wk_radicals << r
    end
  end
  offset += 100
end; nil

