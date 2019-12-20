class Sentence < ActiveRecord::Base
  has_many :sentences_words, dependent: :destroy # Destroy only SentencesWords connection
  has_many :words, through: :sentences_words
  belongs_to :user
  belongs_to :drill
  has_many :sentence_reviews
end

