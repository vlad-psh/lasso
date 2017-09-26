Action.where(action_type: 2).each do |a|
  s = Statistic.find_or_initialize_by(date: a.created_at.to_date)
  s.learned[a.card.element_type] += 1
  s.save
end; nil

Card.where.not(scheduled: nil).each do |c|
  s = Statistic.find_or_initialize_by(date: c.scheduled)
  s.scheduled[c.element_type] += 1
  s.save
end; nil

