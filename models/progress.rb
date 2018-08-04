class Progress < ActiveRecord::Base
  belongs_to :user
  belongs_to :card
  belongs_to :word, primary_key: :seq, foreign_key: :seq
  has_many :actions

#               unlocked  learned  scheduled
#locked         -         -        -
#unlocked       true      ANY      ANY
#just_unlocked  true      -        -
#just_learned   true      true     -
#learned        true      true     ANY
#not_learned    ANY       -        -
#studied        true      true     date
#not_studied    ANY       ANY      -

  scope :locked,        ->{where(unlocked: false)} # THIS WILL ALWAYS BE EMPTY
  scope :unlocked,      ->{where(unlocked: true)}
  scope :just_unlocked, ->{where(learned: false, unlocked: true)}
  scope :just_learned,  ->{where(learned: true, scheduled: nil)}
  scope :any_learned,   ->{where(learned: true)}
  scope :not_learned,   ->{where(learned: false)} # SHOULD INCLUDE CARDS WITH locked == false
  scope :studied,       ->{where.not(scheduled: nil)}
  scope :not_studied,   ->{where(scheduled: nil)} # SHOULD INCLUDE CARDS WITH locked == false

  scope :failed,   ->{where(scheduled: Date.new..Date.today, deck: 0)}
  scope :expired,  ->{where(scheduled: Date.new..Date.today).where.not(deck: 0)}
  # Cards in current level which are not learned yet:
  scope :to_learn, ->{not_learned.where(level: Card.current_level)}


  def self.hash_me
    Hash[*all.map{|p| [p.card_id, p]}.flatten]
  end

  def self.hash2_me
    result = {}
    all.each do |p|
      result[p.seq] ||= []
      result[p.seq] << p
    end
    return result
  end

end

