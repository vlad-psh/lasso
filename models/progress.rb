class Progress < ActiveRecord::Base
  belongs_to :user
  belongs_to :card
  belongs_to :word, primary_key: :seq, foreign_key: :seq
  belongs_to :kanji
  has_many :wk_words, primary_key: :seq, foreign_key: :seq
  has_many :wk_kanji, primary_key: :kanji_id, foreign_key: :kanji_id
  belongs_to :wk_radical
  has_many :actions
  has_and_belongs_to_many :drills

  enum kind: {w: 1, k: 2, r: 3}

  scope :words,    ->{where(kind: :w)}
  scope :kanjis,   ->{where(kind: :k)}
  scope :radicals, ->{where(kind: :r)}

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
  scope :just_unlocked, ->{where(learned_at: nil, unlocked: true)}
  scope :just_learned,  ->{where(deck: 0)}
  scope :any_learned,   ->{where.not(learned_at: nil)}
#  scope :not_learned,   ->{where(learned_at: nil)} # SHOULD INCLUDE CARDS WITH locked == false
#  scope :studied,       ->{where.not(scheduled: nil)}
#  scope :not_studied,   ->{where(scheduled: nil)} # SHOULD INCLUDE CARDS WITH locked == false

#  scope :failed,   ->{where(scheduled: Date.new..Date.today, deck: 0)}
  scope :expired,  ->{where(scheduled: Date.new..Date.today).where.not(deck: 0)}
  # Cards in current level which are not learned yet:
#  scope :to_learn, ->{not_learned.where(level: Card.current_level)}

  include Comparable
  def <=>(anOther)
    sorting_score <=> anOther.sorting_score
  end

  def sorting_score
    return 10 if self.burned_at.present?
    return self.deck if self.deck.present?
    return -1 if self.flagged_at.present?
    return -2
  end

  def self.hash_me(_method)
    result = {}
    all.each do |p|
      result[p.send(_method)] ||= []
      result[p.send(_method)] << p
    end
    return result
  end

  def self.api_props
    return [:id, :deck, :learned_at, :burned_at, :flagged_at, :details]
  end

  def answer!(a)
    # answer should be 'yes', 'no' or 'soso'
    a = a.to_sym

    throw StandardError.new("Unknown answer: #{a}") unless [:correct, :incorrect, :soso, :burn].include?(a)

    if a == :correct
      self.attributes = attributes_of_correct_answer
    elsif a == :incorrect
      self.attributes = attributes_of_incorrect_answer
    elsif a == :soso
      self.attributes = attributes_of_soso_answer
    elsif a == :burn
      self.attributes = {deck: nil, scheduled: nil, transition: nil, burned_at: DateTime.now}
      Action.create(progress: self, user: user, action_type: 'burn')
    end

    if [:correct, :incorrect, :soso].include?(a)
      # Get schedule day with offset
      random_reschedule!
    end

    if self.deck.present? && self.deck != 0 # if not burned and not 'just learned'
      Action.create(progress: self, user: user, action_type: a)

      stats = Statistic.find_or_initialize_by(user: user, date: self.scheduled)
      stats.scheduled[self.kind] += 1
      stats.save
    end

    self.save
  end

  def attributes_of_correct_answer
    _deck = self.deck
    _transition = self.transition

    if Date.today >= self.transition
      _deck += 1 if _deck < 7 # 7th is the highest deck
      _transition += SRS_RANGES[_deck]
      # Move transition date forward by (deck_range/2) if it still less than today
      _transition = Date.today + SRS_RANGES[_deck] / 2 if _transition < Date.today
    end
    _percent = (Date.today - _transition + SRS_RANGES[_deck]) / SRS_RANGES[_deck].to_f
    # percent should not be > 1.0 because of previous condition (with dates)
    return {
      deck: _deck,
      transition: _transition,
# TODO: ADD VARIATION TO SCHEDULE DATE (+/- 20% ?)
      scheduled: Date.today + SRS_RANGES[_deck] * (1 + _percent) # add full next interval + fraction of it
    }
  end

  def attributes_of_soso_answer
    # Leave in the same deck; move transition date forward
    _transition = Date.today + SRS_RANGES[self.deck]
    return {
      deck: self.deck,
      transition: _transition,
      scheduled: _transition
    }
  end

  def attributes_of_incorrect_answer
    _deck = self.deck > 1 ? self.deck - 1 : 1
    return {
      deck: _deck,
      transition: Date.today + SRS_RANGES[_deck],
      scheduled: Date.today + 3
    }
  end

  def html_class
    if self.burned_at.present?
      return :burned
    elsif self.learned_at.present?
      return case self.deck
        when 0..1 then :apprentice
        when 2    then :guru
        when 3    then :master
        when 6..7 then :burned
        else           :enlightened
      end
    elsif self.flagged_at.present?
      return :unlocked
    end
  end

  def api_hash
    result = self.serializable_hash(only: Progress.api_props)
    result[:html_class] = self.html_class
    result = result.merge({
      correct:   (attributes_of_correct_answer[:scheduled]    - Date.today).to_i,
      soso:      (attributes_of_soso_answer[:scheduled]       - Date.today).to_i,
      incorrect: (attributes_of_incorrect_answer[:transition] - Date.today).to_i
    }) if self.deck.present?
    result
  end

  def api_json
    self.api_hash.to_json
  end

  private
  def random_reschedule!
    variation_days = ((self.scheduled - Date.today) * 0.15).to_i
    range_from = self.scheduled - variation_days
    range_to   = self.scheduled + variation_days

    # make 'day: cards count' hash
    day_cards = {}
    (range_from..range_to).each {|d| day_cards[d.strftime()] = 0}
    # There was a strange bug when I've used 'Date' objects as key of day_cards hash
    # sometimes, in following loop/block, day_cards[d] returned nil (but the value was
    # definitely there! (and it even was non-zero)
    # That's why we using strings as keys in this hash
    counts = Progress.where(user: self.user, scheduled: range_from..range_to).group(:scheduled).order('count_all').count
    counts.each {|d,c| day_cards[d.strftime()] += c}

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
    selected_day = Date.parse(vacant_days[0])
    vacant_days.each do |d_str|
      d = Date.parse(d_str)
      if (d - self.scheduled).abs < (selected_day - self.scheduled).abs
        selected_day = d
      end
    end

    puts "### SELECTED #{selected_day} ANCHOR #{self.scheduled} ALL DAYS #{day_cards}"
    return self.scheduled = selected_day
  end

end

