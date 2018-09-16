class Progress < ActiveRecord::Base
  belongs_to :user
  belongs_to :card
  belongs_to :word, primary_key: :seq, foreign_key: :seq
  belongs_to :kanji
  has_many :wk_words, primary_key: :seq, foreign_key: :seq
  belongs_to :wk_radical
  has_many :actions

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
  scope :just_learned,  ->{where(scheduled: nil, burned_at: nil).where.not(learned_at: nil)}
  scope :any_learned,   ->{where.not(learned_at: nil)}
#  scope :not_learned,   ->{where(learned_at: nil)} # SHOULD INCLUDE CARDS WITH locked == false
#  scope :studied,       ->{where.not(scheduled: nil)}
#  scope :not_studied,   ->{where(scheduled: nil)} # SHOULD INCLUDE CARDS WITH locked == false

#  scope :failed,   ->{where(scheduled: Date.new..Date.today, deck: 0)}
  scope :expired,  ->{where(scheduled: Date.new..Date.today, burned_at: nil).where.not(deck: 0)}
  # Cards in current level which are not learned yet:
#  scope :to_learn, ->{not_learned.where(level: Card.current_level)}

  def self.hash_me(_method)
    result = {}
    all.each do |p|
      result[p.send(_method)] ||= []
      result[p.send(_method)] << p
    end
    return result
  end

  def answer_by!(a, user)
    # answer should be 'yes', 'no' or 'soso'
    a = a.to_sym

    throw StandardError.new("Unknown answer: #{a}") unless [:yes, :no, :soso, :burn].include?(a)

    if a == :yes
      move_to_deck_by!(self.deck + 1, user)
      Action.create(progress: self, user: user, action_type: 'correct')
    elsif a == :no
      move_to_deck_by!(self.deck - 1, user, choose_schedule_day_by(self.deck >= 1 ? 1 : 0, user)) # reschedule to +2..+4 days
      Action.create(progress: self, user: user, action_type: 'incorrect')
    elsif a == :soso
      # leave in the same deck
      move_to_deck_by!(self.deck, user)
      Action.create(progress: self, user: user, action_type: 'soso') if self.deck != 0
    elsif a == :burn
      move_to_deck_by!(7, user)
      Action.create(progress: self, user: user, action_type: 'burn')
    end
  end

  def move_to_deck_by!(deck, user, scheduled = nil)
    if self.failed == true
# TODO: made logic clearer/simplier
      # no:   failed  update_deck
      # yes:  -       -
      # soso: failed  -
      # burn: -       update_deck
      self.failed = false if deck > self.deck # answer is correct or burn
      self.deck = deck unless (self.deck == deck) || (self.deck + 1 == deck) # answer is no or burn
    else
      self.failed = true if deck < self.deck # when answer is incorrect
      self.deck = deck
    end

    self.scheduled = scheduled.present? ? scheduled : choose_schedule_day_by(self.deck, user)
    self.save

    if self.deck != 0
      stats = Statistic.find_or_initialize_by(user: user, date: self.scheduled)
      stats.scheduled[self.kind] += 1
      stats.save
    end
  end

  private
  def choose_schedule_day_by(new_deck, user, from_date = Date.today)
    return Date.new(3000, 1, 1) if new_deck == 100 # learned forever

    r = SRS_RANGES[new_deck > 7 ? 7 : new_deck]
    date_range = [from_date + r[0], from_date + r[2]]

    # make 'day: cards count' hash
    day_cards = {}
    (from_date + r[0]..from_date + r[2]).each {|d| day_cards[d] = 0}
    counts = Progress.where(user: user, scheduled: (from_date + r[0])..(from_date + r[2])).group(:scheduled).order('count_all').count
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

