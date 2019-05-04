class WkWord < ActiveRecord::Base
  has_many :wk_kanji_words
  has_and_belongs_to_many :wk_kanji, through: :wk_kanji_words
  belongs_to :word, primary_key: :seq, foreign_key: :seq
  has_many :progresses, primary_key: :seq, foreign_key: :seq

  def self.with_progresses(user)
    elements = all
    progresses = Progress.joins(:wk_words).where(user: user).merge(elements).hash_me(:seq)
    elements.each do |e|
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

  def list_title
    self.title
  end

  def list_desc
    self.meaning.gsub(/,.*/, '')
  end
end

