module WKElementInstance
  def unlock!
    unless self.unlocked_at
      self.unlocked_at = DateTime.now
      self.save
    end
  end

  def learned?
    return self.learned_at ? true : false
  end

  def answer!(a)
    a = a.to_sym
    if a == :yes
      self.deck += 1
      self.passes += 1
      self.reviewed = Date.today
      self.scheduled = choose_schedule_day(self.deck)
      self.save
    elsif a == :no
      self.deck = 0
      self.fails += 1
      self.reviewed = Date.today
      self.scheduled = Date.today
      self.save
    end
  end

  def choose_schedule_day(new_deck)
    ranges = [[0, 0, 0], [2, 3, 4], [6, 7, 8], [12, 14, 16], [25, 30, 35], [50, 60, 70], [100, 120, 140], [200, 240, 280]]
    r = ranges[new_deck > 7 ? 7 : new_deck]
    date_range = [Date.today + r[0], Date.today + r[2]]

    # make 'day: cards count' hash
    day_cards = {}
    (Date.today + r[0]..Date.today + r[2]).each {|d| day_cards[d] = 0}
    [Radical, Kanji, Word].each do |k|
      counts = k.where(scheduled: (Date.today + r[0])..(Date.today + r[2])).group(:scheduled).order('count_all').count
      counts.each {|d,c| day_cards[d] += c}
    end

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

module WKElement
  def failed
    # 'learned_at != nil' automatically because of 'fails != 0'
    self.where(deck: 0).where.not(fails: 0)
  end

  def expired
    # 'learned_at != nil' automatically because of 'deck != 0' and 'scheduled != nil'
    self.where(scheduled: Date.new..Date.today).where.not(deck: 0)
  end

  def just_learned
    self.where(deck: 0, fails: 0).where.not(learned_at: nil)
  end

  def just_unlocked
    self.where(learned_at: nil).where.not(unlocked_at: nil)
  end
end

class Radical < ActiveRecord::Base
  has_and_belongs_to_many :kanjis
  include WKElementInstance
  extend WKElement

  def description
    return self.en
  end

  def learn!
    unless learned?
      self.learned_at = DateTime.now
      self.save
    end

    new_elements = []
    self.kanjis.each do |k|
      unlock = true
      k.radicals.each do |r|
        unlock = false unless r.learned?
      end
      if unlock
        k.unlock!
        new_elements << k
      end
    end
    return new_elements
  end
end

class Kanji < ActiveRecord::Base
  has_and_belongs_to_many :radicals
  has_and_belongs_to_many :words
  include WKElementInstance
  extend WKElement

  def description
    return self.yomi[self.yomi['emph']].split(',')[0].strip
  end

  def learn!
    unless learned?
      self.learned_at = DateTime.now
      self.save
    end

    new_elements = []
    self.words.each do |w|
      unlock = true
      w.kanjis.each do |k|
        unlock = false unless k.learned?
      end
      if unlock
        w.unlock!
        new_elements << w
      end
    end
    return new_elements
  end
end

class Word < ActiveRecord::Base
  has_and_belongs_to_many :kanjis
  include WKElementInstance
  extend WKElement

  def description
    return self.en.first
  end

  def learn!
    unless learned?
      self.learned_at = DateTime.now
      self.save
    end

    return [] # no new elements learned
  end
end
