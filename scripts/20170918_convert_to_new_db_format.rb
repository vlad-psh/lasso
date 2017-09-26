require './app.rb'

Kanji.all.each do |k|
  details = k.details
  details['yomi'] = k.yomi
  details['en'] = k.en
  details['similar'] = k.similar
  details['grade'] = k.grade
  details['freq'] = k.freq
  c = Card.create(element_type: :k,
    level: k.level,
    title: k.title,
    details: details,
    unlocked: (k.unlocked_at ? true : false),
    learned: (k.learned_at ? true : false),
    deck: k.deck,
    scheduled: k.scheduled)
# action 1: unlocked
  Action.create(card: c, action_type: 1,
    created_at: k.unlocked_at, updated_at: k.unlocked_at) if k.unlocked_at
# action 2: learned
  Action.create(card: c, action_type: 2,
    created_at: k.learned_at, updated_at: k.learned_at) if k.learned_at
# action 3: correct answer
  if k.reviewed
    rev_dt = k.reviewed.to_datetime + 15.hours
    Action.create(card: c, action_type: 3,
      created_at: rev_dt, updated_at: rev_dt)
  end
  Action.create(card: c, action_type: 3,
    created_at: k.learned_at,
    updated_at: k.learned_at) if k.reviewed && k.deck == 2
# action 4: incorrect answer (not implemented)

end; nil

Radical.all.each do |k|
  details = k.details
  details['en'] = [k.en]
  c = Card.create(element_type: :r,
    level: k.level,
    title: k.title,
    details: details,
    unlocked: (k.unlocked_at ? true : false),
    learned: (k.learned_at ? true : false),
    deck: k.deck,
    scheduled: k.scheduled)
# action 1: unlocked
  Action.create(card: c, action_type: 1,
    created_at: k.unlocked_at, updated_at: k.unlocked_at) if k.unlocked_at
# action 2: learned
  Action.create(card: c, action_type: 2,
    created_at: k.learned_at, updated_at: k.learned_at) if k.learned_at
# action 3: correct answer
  if k.reviewed
    rev_dt = k.reviewed.to_datetime + 15.hours
    Action.create(card: c, action_type: 3,
      created_at: rev_dt, updated_at: rev_dt)
  end
  Action.create(card: c, action_type: 3,
    created_at: k.learned_at,
    updated_at: k.learned_at) if k.reviewed && k.deck == 2
# action 4: incorrect answer (not implemented)

end; nil

Word.all.each do |k|
  details = k.details
  details['en'] = k.en
  details['readings'] = k.readings
  details['sentences'] = k.sentences
  details['pos'] = k.pos
  c = Card.create(element_type: :w,
    level: k.level,
    title: k.title,
    details: details,
    unlocked: (k.unlocked_at ? true : false),
    learned: (k.learned_at ? true : false),
    deck: k.deck,
    scheduled: k.scheduled)
# action 1: unlocked
  Action.create(card: c, action_type: 1,
    created_at: k.unlocked_at, updated_at: k.unlocked_at) if k.unlocked_at
# action 2: learned
  Action.create(card: c, action_type: 2,
    created_at: k.learned_at, updated_at: k.learned_at) if k.learned_at
# action 3: correct answer
  if k.reviewed
    rev_dt = k.reviewed.to_datetime + 15.hours
    Action.create(card: c, action_type: 3,
      created_at: rev_dt, updated_at: rev_dt)
  end
  Action.create(card: c, action_type: 3,
    created_at: k.learned_at,
    updated_at: k.learned_at) if k.reviewed && k.deck == 2
# action 4: incorrect answer (not implemented)

end; nil


