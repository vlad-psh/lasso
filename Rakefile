require './app.rb'
require 'sinatra/activerecord/rake'

namespace :wakame do
  desc "Shift your schedule to lower count of expired cards"
  task :comeback do
    MAXCARDS = 100
    just_learned_count = Card.just_learned.count
    start_date = Date.today
    while true
      break if Card.where(Card.arel_table[:scheduled].lteq(start_date)).count + just_learned_count <= MAXCARDS
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
        stat1 = Statistic.find_or_create_by(date: d)
        stat2 = Statistic.find_or_create_by(date: (d + date_diff))
        Card.where(scheduled: d).each do |c|
          c.update(scheduled: d + date_diff)
          stat1.scheduled[c.element_type] -= 1
          stat2.scheduled[c.element_type] += 1
        end
        stat1.save
        stat2.save
      end
    else
      puts "You already has a feasible amount of scheduled cards. No need to shift anything."
    end
  end
end
