class Progress < ActiveRecord::Base
  belongs_to :user
  belongs_to :card
  belongs_to :word, primary_key: :seq, foreign_key: :seq
  belongs_to :kanji
  has_many :wk_words, primary_key: :seq, foreign_key: :seq
  has_many :wk_kanji, primary_key: :kanji_id, foreign_key: :kanji_id
  belongs_to :wk_radical
  has_and_belongs_to_many :drills
  has_many :srs_progresses

  scope :words,    ->{where.not(seq: nil)}
  scope :kanjis,   ->{where.not(kanji_id: nil)}
  scope :radicals, ->{where.not(wk_radical_id: nil)}

  scope :learned,  ->{where.not(learned_at: nil)}

  scope :by_user, ->(user) {where(user: user)}

  include Comparable
  def <=>(anOther)
    sorting_score <=> anOther.sorting_score
  end

  def sorting_score
    return 3 if self.burned_at.present?
    return 2 if self.learned_at.present?
    return 1 if self.flagged
    return 0
  end

  def self.hash_me(_method)
    result = {}
    all.each do |p|
      result[p.send(_method)] ||= []
      result[p.send(_method)] << p
    end
    return result
  end

  def kind
    return 'w' if seq.present?
    return 'k' if kanji_id.present?
    return 'r' if wk_radical_id.present?
  end

  def learn!
    throw StandardError.new("Already learned") if learned_at.present?

    self.update(learned_at: DateTime.now)

    stats = Statistic.find_or_initialize_by(user: user, date: Date.today)
    stats.learned[self.kind] += 1
    stats.save
  end

  def burn!
    return if burned_at.present?

    self.update(burned_at: DateTime.now)
  end

  def answer!(a, opts = {})
    return if burned_at.present? # no action required for

    learning_type = opts[:learning_type] || 0 # default learning_type is reading_question == 0
    drill = opts[:drill] || nil

    a = a.to_sym
    throw StandardError.new("Unknown answer: #{a}") unless [:correct, :incorrect, :soso].include?(a)

    self.learn! unless self.learned_at.present?

    srs_progress = SrsProgress.find_by(progress: self, learning_type: learning_type) ||
        SrsProgress.create(learning_type: learning_type, progress: self, user: self.user, deck: 0, transition: Date.today)
    srs_progress.answer!(a, drill)
  end

  def html_class
    if self.burned_at.present?
      return :burned
    elsif self.learned_at.present?
      return :guru
    elsif self.flagged
      return :apprentice
    end
    return :pristine
  end

  def self.api_props
    return [:id, :learned_at, :burned_at, :flagged, :comment]
  end

  def api_hash
    result = self.serializable_hash(only: Progress.api_props)
    result[:html_class] = self.html_class
    result
  end

  def api_json
    self.api_hash.to_json
  end
end

