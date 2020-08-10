class WkKanji < ActiveRecord::Base
  self.table_name = 'wk_kanji'
  has_many :wk_kanji_words
  has_and_belongs_to_many :wk_words, through: :wk_kanji_words
  has_many :wk_kanji_radicals
  has_and_belongs_to_many :wk_radicals, through: :wk_kanji_radicals
  belongs_to :kanji
  has_many :progresses, primary_key: :kanji_id, foreign_key: :kanji_id

  def list_title
    title
  end

  def list_desc
    self.readings.select{|i| i['primary'] == true}.map{|i| i['reading']}.join(', ')
  end
end

