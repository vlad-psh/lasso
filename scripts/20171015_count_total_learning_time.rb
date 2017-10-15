total = 0
prev = nil
Action.where(action_type: 2..4).order(created_at: :asc).each do |a|
  unless prev
    prev = a
    next
  end
  diff = a.created_at - prev.created_at
  if diff < 300 && diff > 0.1 # in seconds
    total += diff
  elsif a.action_type == 2
    total += 120 # 2 minutes for learning
  else
    total += 20 # 20 seconds for answering
  end
  prev = a
end; nil
puts "Total: #{(total/60/60).round(1)} hours"

