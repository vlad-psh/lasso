class WordTitle < ActiveRecord::Base
  belongs_to :word, primary_key: :seq, foreign_key: :seq
end

