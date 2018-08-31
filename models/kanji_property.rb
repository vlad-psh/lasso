class KanjiProperty < ActiveRecord::Base
  belongs_to :kanji

  enum kind: {
    on: 1,
    kun: 2,
    nanori: 3,
    english: 4
  }
end

