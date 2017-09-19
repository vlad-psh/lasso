class Card < ActiveRecord::Base
  has_many :actions
  # low-level:
  has_many :cards_relations
  has_many :inverse_cards_relations, class_name: 'CardsRelation', foreign_key: :relation_id
  # high-level:
  has_many :relations, through: :cards_relations
  has_many :inverse_relations, through: :inverse_cards_relations, source: :card

# =====================================
# OBJECT

  scope :radicals, ->{where(element_type: 'r')}
  scope :kanjis,   ->{where(element_type: 'k')}
  scope :words,    ->{where(element_type: 'w')}

  scope :failed,   ->{where(scheduled: Date.new..Date.today, deck: 0)}
  scope :expired,  ->{where(scheduled: Date.new..Date.today).where.not(deck: 0)}
  scope :just_learned,  ->{where(learned: true, scheduled: nil)}
  scope :just_unlocked, ->{where(learned: false, unlocked: true)}

# =====================================
# INSTANCE

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

  def radical?
    element_type == 'r' ? true : false
  end

  def kanji?
    element_type == 'k' ? true : false
  end

  def word?
    element_type == 'w' ? true : false
  end

  def description
    if element_type == 'k'
      return detailsb['yomi'][detailsb['yomi']['emph']]
    else
      return detailsb['en'].first
    end
  end

  def unlock!
    unless self.unlocked
      self.unlocked = true
      self.save
      Action.create(card: self, action_type: 1)
    end
  end

  def learn!
    return if learned

    self.learned = true
    self.save
    Action.create(card: self, action_type: 2)

    new_elements = []
    if self.radical?
      self.kanjis.each do |k|
        begin
          k.radicals.each {|r| throw StandardError.new('Will not be unlocked') unless r.learned }
          k.unlock!
          new_elements << k
        rescue
          next
        end
      end
    elsif self.kanji?
      self.words.each do |w|
        begin
          w.kanjis.each {|k| throw StandardError.new('Will not be unlocked') unless k.learned }
          w.unlock!
          new_elements << w
        rescue
          next
        end
      end
    end
    return new_elements
  end

  def answer!(a)
    # answer should be 'yes' or 'no'
    a = a.to_sym

    if a == :yes
      self.deck += 1
      self.scheduled = choose_schedule_day(self.deck)
      self.save
      Action.create(card: self, action_type: 3) # 3 = correct answer
    elsif a == :no
      self.deck = 0
      self.scheduled = Date.today
      self.save
      Action.create(card: self, action_type: 4) # 4 = incorrect answer
    end
  end


  private
  def choose_schedule_day(new_deck)
    ranges = [[0, 0, 0], [2, 3, 4], [6, 7, 8], [12, 14, 16], [25, 30, 35], [50, 60, 70], [100, 120, 140], [200, 240, 280]]
    r = ranges[new_deck > 7 ? 7 : new_deck]
    date_range = [Date.today + r[0], Date.today + r[2]]

    # make 'day: cards count' hash
    day_cards = {}
    (Date.today + r[0]..Date.today + r[2]).each {|d| day_cards[d] = 0}
    counts = Card.where(scheduled: (Date.today + r[0])..(Date.today + r[2])).group(:scheduled).order('count_all').count
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
    optimal_day = Date.today + r[1]
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
end

class CardsRelation < ActiveRecord::Base
  belongs_to :card
  belongs_to :relation, class_name: 'Card'
end
