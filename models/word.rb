class Word < ActiveRecord::Base
  belongs_to :card
  has_many :progresses, primary_key: :card_id, foreign_key: :card_id

  has_many :sentences_words, primary_key: :seq, foreign_key: :word_seq
  has_many :sentences, through: :sentences_words

  has_many :short2long_connections, class_name: 'WordConnection', primary_key: :seq, foreign_key: :short_seq
  has_many :long2short_connections, class_name: 'WordConnection', primary_key: :seq, foreign_key: :long_seq
  has_many :long_words,  through: :short2long_connections
  has_many :short_words, through: :long2short_connections

  def self.with_progress(user)
    progresses = Progress.joins(:word).merge( all.unscope(:select) ).where(user: user).hash_me
    all.each do |c|
      c.progress = progresses[c.card_id]
    end
  end

  def progress=(value)
    @_progress = value
  end

  def progress
    return @_progress if defined?(@_progress)
    throw StandardError.new("'progress' property can be accessed only when elements have been selected with 'with_progress' method")
  end

  def krebs # All keb's and reb's
    kebs = kele ? kele.map{|i| i['keb']} : []
    rebs = rele ? rele.map{|i| i['reb']} : []
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
end

