class Activity < ActiveRecord::Base
  belongs_to :user

  enum category: {
        search:  1,
        kanji:   2,
        kokugo:   3,
  }
end

