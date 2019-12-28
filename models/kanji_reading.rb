class KanjiReading < ActiveRecord::Base
  has_one :kanji, primary_key: :title, foreign_key: :title

  enum kind: {on: 0, kun: 1, nanori: 2}
end

