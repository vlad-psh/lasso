require './app.rb'
require 'sinatra/activerecord/rake'

namespace :wakame do
  desc "Shift your schedule to lower count of expired cards"
  task :comeback do
    MAXCARDS = 59
    # start looking from day after when latest 'learning' action was occurred
    # that's because we'll rewrite Statistics table and we don't want to
    latest_learn_date = Action.where(action_type: 2).order(created_at: :desc).first.created_at.to_date
    just_learned_count = Card.just_learned.count
    start_date = Date.today
    while true
      break if Card.where(Card.arel_table[:scheduled].lteq(start_date)).count + just_learned_count <= MAXCARDS
      break if start_date <= latest_learn_date + 1
      start_date -= 1
    end
    date_diff = Date.today - start_date

    if date_diff > 0
      # start_date is a date with count of items not more than MAXCARDS
      # we should shift everything after that date
      start_date += 1
      puts "Cards, scheduled for #{start_date} and later will be shifted for #{date_diff.to_i} days forward"

      dates = Card.where(Card.arel_table[:scheduled].gteq(start_date)).group(:scheduled).order(scheduled: :desc).pluck(:scheduled)
      dates.each do |d|
        print "#{d} "
        Card.where(scheduled: d).update_all(scheduled: (d + date_diff))
      end
      puts

      puts "Rebuilding statistics..."
      counters = {}
      Statistic.where(Statistic.arel_table[:date].gteq(start_date)).delete_all
      Card.group(:scheduled, :element_type).count.each do |det, c|
        d, et = det
        counters[d] ||= {'r' => 0, 'k' => 0, 'w' => 0}
        counters[d][et] = c
      end
      counters.each do |d, ch|
        Statistic.create(date: d, scheduled: ch)
      end
    else
      puts "You already has a feasible amount of scheduled cards. No need to shift anything."
    end
  end
end
