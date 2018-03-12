INFODIC = {
  :r => {singular: :radical, plural: :radicals, japanese: '部首'},
  :k => {singular: :kanji, plural: :kanjis, japanese: '漢字'},
  :w => {singular: :word, plural: :words, japanese: '言葉'}
}

class Card < ActiveRecord::Base
  has_many :actions
  has_many :user_cards
  # low-level:
  has_many :cards_relations
  has_many :inverse_cards_relations, class_name: 'CardsRelation', foreign_key: :relation_id
  # high-level:
  has_many :relations, through: :cards_relations
  has_many :inverse_relations, through: :inverse_cards_relations, source: :card

  attr_accessor :uinfo # used to store user info (UserCard)

  def self.with_uinfo(user)
    user_cards = UserCard.joins(:card).merge(all).where(user: user).hash_me
    all.each do |c|
      c.uinfo = user_cards[c.id] if user_cards[c.id].present?
    end
  end

# =====================================
# OBJECT

  scope :radicals, ->{where(element_type: 'r')}
  scope :kanjis,   ->{where(element_type: 'k')}
  scope :words,    ->{where(element_type: 'w')}

  def radicals
    raise StandardError("Unknown method for type #{self.element_type}") unless self.element_type == 'k'
    self.relations.where(element_type: 'r')
  end

  def words
    raise StandardError("Unknown method for type #{self.element_type}") unless self.element_type == 'k'
    self.relations.where(element_type: 'w')
  end

  def kanjis
    raise StandardError("Unknown method for type #{self.element_type}") if self.element_type == 'k'
    return self.inverse_relations
  end

  def same_type
    return case element_type
        when 'r' then Card.radicals
        when 'k' then Card.kanjis
        when 'w' then Card.words
        else nil
    end
  end

  def radical?
    element_type == 'r' ? true : false
  end

  def kanji?
    element_type == 'k' ? true : false
  end

  def word?
    element_type == 'w' ? true : false
  end

  def tplural
    return INFODIC[element_type.to_sym][:plural]
  end

  def tsingular
    return INFODIC[element_type.to_sym][:singular]
  end

  def description
    if element_type == 'k'
      return detailsb['yomi'][detailsb['yomi']['emph']]
    else
      return detailsb['en'].first
    end
  end

  def pitch_str
    throw StandardError.new("Card##{self.id} is not a word") unless self.word?

    return '?' unless self.detailsb['pitch']
    pitches = []
    self.detailsb['pitch'].each do |reading,pitch|
      pitches << pitch if self.detailsb['readings'].include?(reading)
    end
    return pitches.flatten.join(', ')
  end

  def pitch_detailed_str
    throw StandardError.new("Card##{self.id} is not a word") unless self.word?

    return 'nil' unless self.detailsb['pitch']
    return self.detailsb['pitch'].to_s
  end

  def unlock_by!(user)
    uinfo = UserCard.find_or_create_by(card: self, user: user)

    unless uinfo.unlocked
      uinfo.unlocked = true
      uinfo.save
      Action.create(card: self, user: user, action_type: 1)
    end
  end

  def learn_by!(user)
    uinfo = UserCard.find_by(card: self, user: user)
    throw StandardError.new("Card info not found") unless uinfo.present?
    throw StandardError.new("Already learned") if uinfo.learned

    uinfo.learned = true
    uinfo.deck = 0
    uinfo.save

    Action.create(card: self, user: user, action_type: 2)

    stats = Statistic.find_or_initialize_by(user: user, date: Date.today)
    stats.learned[self.element_type] += 1
    stats.save

    new_elements = []
    # Unlock linked elements (kanjis for radicals; words for kanjis)
    if self.radical?
      self.kanjis.each do |k|
        begin
          # check if all radicals are already unlocked
          k.radicals.with_uinfo(user).each {|r| throw StandardError.new('Will not be unlocked') unless r.uinfo.learned }
          k.unlock_by!(user)
          new_elements << k
        rescue
          next
        end
      end
    elsif self.kanji?
      self.words.each do |w|
        begin
          w.kanjis.with_uinfo(user).each {|k| throw StandardError.new('Will not be unlocked') unless k.uinfo.learned }
          w.unlock_by!(user)
          new_elements << w
        rescue
          next
        end
      end
    end

    # Unlock radicals for next level if there was last learned card in current level
    new_current_level = user.current_level
    if (self.level < new_current_level)
      Card.radicals.where(level: new_current_level).with_uinfo(user).each do |r|
        unless (r.uinfo && r.uinfo.unlocked)
          r.unlock_by!(user)
          new_elements << r
        end
      end
    end

    return new_elements
  end

  def answer_by!(a, user)
    # answer should be 'yes', 'no' or 'soso'
    a = a.to_sym

    uinfo = UserCard.find_by(card: self, user: user)
    throw StandardError.new("Card info not found") unless uinfo.present?

    if a == :yes
      self.move_to_deck_by!(uinfo.deck + 1, user)
      Action.create(card: self, user: user, action_type: 3) # 3 = correct answer
    elsif a == :no
      self.move_to_deck_by!(0, user)
      Action.create(card: self, user: user, action_type: 4) # 4 = incorrect answer
    elsif a == :soso
      self.move_to_deck_by!(uinfo.deck >= 3 ? 3 : uinfo.deck, user)
      Action.create(card: self, user: user, action_type: 5) if uinfo.deck != 0 # 5 = soso answer
    elsif a == :burn
      self.move_to_deck_by!(100, user)
      Action.create(card: self, user: user, action_type: 6)
    else
      throw StandardError.new("Unknown answer: #{a}")
    end
  end

  def move_to_deck_by!(deck, user)
    uinfo = UserCard.find_by(card: self, user: user)
    throw StandardError.new("Card info not found") unless uinfo.present?
    
    uinfo.deck = deck
    uinfo.scheduled = choose_schedule_day_by(deck, user)
    uinfo.save

    if deck != 0
      stats = Statistic.find_or_initialize_by(user: user, date: uinfo.scheduled)
      stats.scheduled[self.element_type] += 1
      stats.save
    end
  end

  private
  def choose_schedule_day_by(new_deck, user, from_date = Date.today)
    return Date.new(3000, 1, 1) if new_deck == 100 # learned forever

    ranges = [[0, 0, 0], [2, 3, 4], [6, 7, 8], [12, 14, 16], [25, 30, 35], [50, 60, 70], [100, 120, 140], [200, 240, 280]]
    r = ranges[new_deck > 7 ? 7 : new_deck]
    date_range = [from_date + r[0], from_date + r[2]]

    # make 'day: cards count' hash
    day_cards = {}
    (from_date + r[0]..from_date + r[2]).each {|d| day_cards[d] = 0}
    counts = UserCard.where(user: user, scheduled: (from_date + r[0])..(from_date + r[2])).group(:scheduled).order('count_all').count
    counts.each {|d,c| day_cards[d] += c}

    # transpose hash to 'cards count: [days]'
    cards_days = {}
    day_cards.each do |k,v|
      if cards_days[v]
        cards_days[v] << k
      else
        cards_days[v] = [k]
      end
    end

    # select days with minimal cards count
    vacant_days = cards_days[cards_days.keys.min]
    optimal_day = from_date + r[1]
    selected_day = vacant_days[0]
    vacant_days.each do |d|
      if (d - optimal_day).abs < (selected_day - optimal_day).abs
        selected_day = d
      end
    end

    puts "### SELECTED #{selected_day} OPTIMAL #{optimal_day} ALL DAYS #{day_cards}"
    return selected_day
  end

end

class Action < ActiveRecord::Base
  belongs_to :card
  belongs_to :user
end

class CardsRelation < ActiveRecord::Base
  belongs_to :card
  belongs_to :relation, class_name: 'Card'
end

class Statistic < ActiveRecord::Base
  belongs_to :user

  def learned_total
    return learned['r'] + learned['k'] + learned['w']
  end

  def scheduled_total
    return scheduled['r'] + scheduled['k'] + scheduled['w']
  end
end

class Note < ActiveRecord::Base
  belongs_to :user
end

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
    Card.joins(:user_cards).merge(UserCard.where(learned: false, unlocked: true, user_id: self.id)).order(level: :asc).first.level || 1
#    self.not_learned.order(level: :asc).first.level
  end
end

class UserCard < ActiveRecord::Base
  belongs_to :user
  belongs_to :card

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

end
