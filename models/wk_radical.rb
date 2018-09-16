class WkRadical < ActiveRecord::Base
  has_and_belongs_to_many :wk_kanji, through: :wk_kanji_radicals
  has_many :progresses

  def description
    details['en'].first
  end
end

