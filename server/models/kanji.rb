require_relative './progressable.rb'

class Kanji < ActiveRecord::Base
  self.table_name = 'kanji'
  has_many :progresses
  has_one :wk_kanji
  has_many :kanji_readings, primary_key: :title, foreign_key: :title

  include Progressable

  def list_title
    self.title
  end

  def list_desc
    if self.association_cached?(:wk_kanji)
      return wk_kanji.list_desc
    else
      return self.english ? self.english[0] : '?'
    end
  end
end

