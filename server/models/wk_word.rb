class WkWord < ActiveRecord::Base
  has_many :wk_kanji_words
  has_and_belongs_to_many :wk_kanji, through: :wk_kanji_words
  belongs_to :word, primary_key: :seq, foreign_key: :seq
  has_many :progresses, primary_key: :seq, foreign_key: :seq

  def list_title
    self.title
  end

  def list_desc
    self.meaning.gsub(/,.*/, '')
  end
end

