class Statistic < ActiveRecord::Base
  belongs_to :user

  def learned_total
    return learned['r'] + learned['k'] + learned['w']
  end

  def scheduled_total
    return scheduled['r'] + scheduled['k'] + scheduled['w']
  end
end

