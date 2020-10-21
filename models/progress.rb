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

  LEITNER_BOXES = [[0,8,5,1],[1,9,6,2],[2,0,7,3],[3,1,8,4],[4,2,9,5],[5,3,0,6],[6,4,1,7],[7,5,2,8],[8,6,3,9],[9,7,4,0]]
  scope :srs_expired, ->(learning_type, current_leitner_session) {
    joins(:srs_progresses) \
    .where(srs_progresses: {learning_type: learning_type, leitner_box: LEITNER_BOXES[current_leitner_session]}) \
    .where(burned_at: nil) \
    .where(SrsProgress.arel_table[:leitner_combo].lt(4)) \
    .where.not(srs_progresses: {leitner_last_reviewed_at_session: current_leitner_session})
  }
  scope :srs_failed, ->(learning_type, current_leitner_session) {
    joins(:srs_progresses) \
    .where(srs_progresses: {learning_type: learning_type, leitner_box: nil}) \
    .where(burned_at: nil) \
    .where.not(srs_progresses: {leitner_last_reviewed_at_session: [current_leitner_session, nil, 10]})
  }
  # with empty leitner* (drill) progress (ie. has SrsProgress object, but never answered in drill scope)
  scope :srs_new, ->(learning_type) {
    joins(:srs_progresses) \
    .where(srs_progresses: {learning_type: learning_type, leitner_last_reviewed_at_session: nil}) \
    .where(burned_at: nil)
  }
  # without any SrsProgress records (with corresponding learning_type)
  scope :srs_nil, ->(learning_type) {
    aSrs = SrsProgress.arel_table
    aProg = Progress.arel_table
    join_on = aSrs.create_on(
      aSrs[:learning_type] \
        .eq(learning_type) \
        .and(aSrs[:progress_id].eq(aProg[:id]))
    )
    outer_join = aProg.create_join(aSrs, join_on, Arel::Nodes::OuterJoin)
    joins(outer_join).where(srs_progresses: {id: nil}, burned_at: nil)
  }

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

  def to_sentence
    Sentence.new(
      structure: [{'seq' => self.seq, 'text' => self.title, 'base' => self.title}],
    )
  end
end

