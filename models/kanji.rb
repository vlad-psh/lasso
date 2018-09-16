class Kanji < ActiveRecord::Base
  self.table_name = 'kanji'
  has_many :kanji_properties
  has_many :progresses
end

