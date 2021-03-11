class SentenceReview < ActiveRecord::Base
  belongs_to :user
  belongs_to :sentence

  enum learning_type: {reading: 0, writing: 1, listening: 2}

end
