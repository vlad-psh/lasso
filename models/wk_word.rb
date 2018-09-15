class WkWord < ActiveRecord::Base
  has_and_belongs_to_many :wk_kanji, through: :wk_kanji_words
  belongs_to :word, primary_key: :seq, foreign_key: :seq
end

