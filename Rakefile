require './app.rb'
require 'sinatra/activerecord/rake'

namespace :wakame do
  desc "Shift your schedule to lower count of expired cards"
  task :comeback do
    start_date = Card.order(scheduled: :asc).first.scheduled
    while Card.where(Card.arel_table[:scheduled].lteq(start_date)).count < 50
      start_date += 1
    end
    date_diff = Date.today - start_date + 1

    if date_diff > 0
      puts "Cards, scheduled for #{start_date} and later will be shifted for #{date_diff.to_i} days forward"
      dates = Card.where(Card.arel_table[:scheduled].gteq(start_date)).group(:scheduled).pluck(:scheduled)
      dates.each do |d|
        Card.where(scheduled: d).update_all(scheduled: (d + date_diff))
      end
    else
      puts "You already have a feasible amount of scheduled cards. No need to shift anything."
      return
    end
  end
end
