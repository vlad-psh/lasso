class WkKanji < ActiveRecord::Base
  self.table_name = 'wk_kanji'
  has_and_belongs_to_many :wk_words, through: :wk_kanji_words
  has_and_belongs_to_many :wk_radicals, through: :wk_kanji_radicals
  has_many :progresses
end

