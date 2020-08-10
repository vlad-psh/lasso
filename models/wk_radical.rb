class WkRadical < ActiveRecord::Base
  has_many :wk_kanji_radicals
  has_and_belongs_to_many :wk_kanji, through: :wk_kanji_radicals
  has_many :progresses

  def list_title
    return title
  end

  def list_desc
    meaning.try(:gsub, /,.*/, '')
  end
end

