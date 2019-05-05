class User < ActiveRecord::Base
  has_many :statistics
  has_many :actions
  has_many :notes
  has_many :user_cards

  def set_password(pwd)
    self.salt = SecureRandom.hex
    self.pwhash = Digest::SHA256.hexdigest(pwd + self.salt)
    self.save
  end

  def check_password(pwd)
    return Digest::SHA256.hexdigest(pwd + self.salt) == self.pwhash
  end

  def current_level
    Action.where(user: self, action_type: :levelup).count + 1
  end

  def comeback!(maxcards = 100)
    just_learned_count = self.user_cards.just_learned.count
    start_date = Date.today
    while true
      break if Progress.where(Progress.arel_table[:scheduled].lteq(start_date)).where(user: self).count + just_learned_count <= maxcards
      start_date -= 1
    end
    date_diff = Date.today - start_date

    if date_diff > 0
      # start_date is a date with count of items not more than MAXCARDS
      # we should shift everything after that date
      start_date += 1

      dates = Progress.where( Progress.arel_table[:scheduled].gteq(start_date)
              ).where(user: self).group(:scheduled).order(scheduled: :desc).pluck(:scheduled)
      dates.each do |d|
        print "#{d} "
        stat1 = Statistic.find_or_create_by(user: self, date: d)
        stat2 = Statistic.find_or_create_by(user: self, date: (d + date_diff))
        Progress.eager_load(:card).where(user: self, scheduled: d).each do |c|
          c.update(scheduled: d + date_diff)
          stat1.scheduled[c.card.element_type] -= 1
          stat2.scheduled[c.card.element_type] += 1
        end
        stat1.save
        stat2.save
      end

      puts "Cards, scheduled for #{start_date} and later have been shifted for #{date_diff.to_i} days forward"
    else
      puts "You already has a feasible amount of scheduled cards. No need to shift anything."
    end
  end

  def learn_time(day = nil) # If day == nil, calculate TOTAL learn time
    total = 0
    prev = nil

    actions = Action.where(action_type: 2..4, user_id: self.id)
    actions = actions.where(created_at: day..(day+1)) if day.present?

    actions.order(created_at: :asc).each do |a|
      unless prev
        prev = a
        next
      end
      diff = a.created_at - prev.created_at
      if diff < 300 && diff > 0.1 # in seconds
        total += diff
      elsif a.action_type == 'learned'
        total += 120 # 2 minutes for learning
      else
        total += 20 # 20 seconds for answering
      end
      prev = a
    end

    puts "Total learn time#{day.present? ? ' at ' + day.to_s : ''}: #{(total/60/60).round(1)} hours"
  end
end

