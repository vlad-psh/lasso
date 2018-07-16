class Action < ActiveRecord::Base
  belongs_to :card
  belongs_to :user

  enum action_type: {
        unlocked:  1,
        learned:   2,
        correct:   3,
        incorrect: 4,
        soso:      5,
        burn:      6,
        levelup:   7
  }
end

