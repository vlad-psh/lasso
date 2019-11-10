class SrsProgress < ActiveRecord::Base
  belongs_to :user
  belongs_to :progress
  has_many :actions

  enum learning_type: {reading_question: 0, kanji_question: 1, listening_question: 2}
  enum kind: {radical: 0, kanji: 1, word: 2, r: 0, k: 1, w: 2}

  scope :words,    ->{where(kind: :word)}
  scope :kanjis,   ->{where(kind: :kanji)}
  scope :radicals, ->{where(kind: :radical)}

  def answer!(a)
    # answer should be 'yes', 'no' or 'soso'
    a = a.to_sym

    if a == :correct
      self.attributes = attributes_of_correct_answer
    elsif a == :incorrect
      self.attributes = attributes_of_incorrect_answer
    elsif a == :soso
      self.attributes = attributes_of_soso_answer
    end

    Action.create(srs_progress: self, user: user, action_type: a)

    self.reviewed_at = DateTime.now
    self.save
  end

  def print_attrs
    puts "correct:   #{attributes_of_correct_answer}"
    puts "soso:      #{attributes_of_soso_answer}"
    puts "incorrect: #{attributes_of_incorrect_answer}"
  end

  def attributes_of_correct_answer
    _deck = self.deck
    _transition = self.transition

    if Date.today <= self.transition && self.last_answer != 'correct'
      if self.last_answer == 'soso'
        return {scheduled: Date.today + SRS_RANGES[self.deck]}
      elsif self.last_answer == 'incorrect'
        return {scheduled: Date.today < self.scheduled ? Date.today + 3 : self.transition}
      end
    end

    if Date.today >= self.transition
      _deck += 1 if _deck < 7 # 7th is the highest deck
      _transition += SRS_RANGES[_deck]
      # Move transition date forward by (deck_range/2) if it still less than today
      _transition = Date.today + SRS_RANGES[_deck] / 2 if _transition < Date.today
    end
    _percent = (Date.today - _transition + SRS_RANGES[_deck]) / SRS_RANGES[_deck].to_f
    # percent should not be > 1.0 because of previous condition (with dates)

# TODO: ADD VARIATION TO SCHEDULE DATE (+/- 20% ?)
# UPD: Maybe no need to (because we now doesn't gave Statistic.schedule and graph of upcoming elements counts)
    add_to_scheduled = SRS_RANGES[_deck] * (1 + _percent) # add full next interval + fraction of it
    add_to_scheduled = SRS_RANGES.last if add_to_scheduled > SRS_RANGES.last # should not be > 240 (or...? maybe allow?)
    return {
      deck: _deck,
      transition: _transition,
      scheduled: Date.today + add_to_scheduled,
      last_answer: :correct
    }
  end

  def attributes_of_soso_answer
    if Date.today <= self.transition && self.last_answer == 'incorrect'
      return {scheduled: Date.today < self.scheduled ? Date.today + 3 : self.transition}
    end

    # Leave in the same deck; move transition date forward
    _transition = Date.today + SRS_RANGES[self.deck]
    return {
      deck: self.deck,
      transition: _transition,
      scheduled: _transition,
      last_answer: :soso
    }
  end

  def attributes_of_incorrect_answer
    _deck = self.deck > 1 && self.last_answer != 'incorrect' ? self.deck - 1 : self.deck
    return {
      deck: _deck,
      transition: Date.today + SRS_RANGES[_deck],
      scheduled: _deck > 0 ? Date.today + 3 : Date.today,
      last_answer: :incorrect
    }
  end

  private
  def random_reschedule!
# Deprecated method
# Can be useful in future
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
    counts = SrsProgress.where(user: self.user, scheduled: range_from..range_to).group(:scheduled).order('count_all').count
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

