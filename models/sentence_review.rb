class SentenceReview < ActiveRecord::Base
  belongs_to :user
  belongs_to :sentence

  enum learning_type: {reading_question: 0, kanji_question: 1, listening_question: 2}

end
