class Word < ActiveRecord::Base
  has_many :wk_words, primary_key: :seq, foreign_key: :seq
  has_many :word_titles, primary_key: :seq, foreign_key: :seq
  has_many :progresses, primary_key: :seq, foreign_key: :seq
  has_many :word_details, primary_key: :seq, foreign_key: :seq

  has_many :sentences_words, primary_key: :seq, foreign_key: :word_seq
  has_many :sentences, through: :sentences_words

  has_many :short2long_connections, class_name: 'WordConnection', primary_key: :seq, foreign_key: :short_seq
  has_many :long2short_connections, class_name: 'WordConnection', primary_key: :seq, foreign_key: :long_seq
  has_many :long_words,  through: :short2long_connections
  has_many :short_words, through: :long2short_connections

  def self.with_progresses(user)
    elements = all
    progresses = Progress.joins(:word).where(user: user).merge(elements).hash_me(:seq)
    elements.each do |e|
      # word can have multiple progresses per user (different variants of writing/reading)
      e.user_progresses = progresses[e.seq]
    end
  end

  def user_progresses=(value)
    @_user_progresses = value
  end

  def user_progresses
    return @_user_progresses if defined?(@_user_progresses)
    throw StandardError.new("'user_progresses' property can be accessed only when elements have been selected with 'with_progresses' method")
  end

  def best_user_progress
    return nil unless @_user_progresses.present?
    @_user_progresses.sort.last
  end

  def krebs # All keb's and reb's
    return [*kebs, *rebs].compact
  end

  def burn_by!(user)
    progress = Progress.find_or_create_by(seq: self.seq, user: user)
    throw StandardError.new("Already burned") if progress.burned_at

    progress.burned_at = DateTime.now
    progress.save

    Action.create(user: user, progress: progress, action_type: :burn)

    return true
  end

  def list_title
    self.kebs ? self.kebs[0] : self.rebs[0]
  end

  def list_desc
    meaning = self.en[0]['gloss'][0]
    meaning.length > 25 ? meaning = meaning[0..20] + '...' : meaning
  end

  def kreb_min_length
    rebs.present? ? rebs.map{|i|i.length}.min : 100
  end
end

