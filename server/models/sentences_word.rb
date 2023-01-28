class SentencesWord < ActiveRecord::Base
  belongs_to :sentence
  belongs_to :word, primary_key: :seq, foreign_key: :word_seq
end

