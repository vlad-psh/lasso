class WordDetail < ActiveRecord::Base
  belongs_to :user
  belongs_to :word, primary_key: :seq, foreign_key: :seq
end

