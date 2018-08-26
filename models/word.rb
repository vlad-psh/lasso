class Word < ActiveRecord::Base
  has_many :cards, primary_key: :seq, foreign_key: :seq
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
    ww = all
    progresses = Progress.where(user: user, seq: ww.map{|w|w.seq}).hash2_me
    ww.each do |w|
      w.user_progresses = progresses[w.seq]
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
    @_user_progresses.sort{|a,b| (a.deck||0) <=> (b.deck||0)}.last
  end

  def krebs # All keb's and reb's
    return [*kebs, *rebs].compact
  end

  def kanji_objects
    Card.kanjis.where(title: self.kanji.split('')).map{|i| [i.title, i]}.to_h
  end

  def kanji_objects_with_progress(user)
    Card.kanjis.where(title: self.kanji.split('')).with_progress(user).map{|i| [i.title, i]}.to_h
  end

  def all_sentences
    Sentence.joins(:sentences_words).merge(SentencesWord.where(word_seq: [seq, *long_words.pluck(:seq)]))
  end

  def burn_by!(user)
    progress = Progress.find_or_create_by(seq: self.seq, user: user)
    throw StandardError.new("Already burned") if progress.burned_at

    progress.burned_at = DateTime.now
    progress.save

    Action.create(user: user, progress: progress, action_type: :burn)

    return true
  end
end

