class Sentence < ActiveRecord::Base
  has_many :sentences_words
  has_many :words, through: :sentences_words
end

