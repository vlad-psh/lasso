class WkKanji < ActiveRecord::Base
  self.table_name = 'wk_kanji'
  has_many :wk_kanji_words
  has_and_belongs_to_many :wk_words, through: :wk_kanji_words
  has_many :wk_kanji_radicals
  has_and_belongs_to_many :wk_radicals, through: :wk_kanji_radicals
  belongs_to :kanji
  has_many :progresses, primary_key: :kanji_id, foreign_key: :kanji_id

  def self.with_progresses(user)
    elements = all
    progresses = Progress.joins(:wk_kanji).where(user: user).merge(elements).hash_me(:kanji_id)
    elements.each do |e|
      e.user_progresses = progresses[e.kanji_id]
    end
  end

  def user_progresses=(value)
    @_user_progresses = value
  end

  def user_progresses
    return @_user_progresses if defined?(@_user_progresses)
    throw StandardError.new("'user_progresses' property can be accessed only when elements have been selected with 'with_progresses' method")
  end

  def list_title
    title
  end

  def list_desc
    self.readings.select{|i| i['primary'] == true}.map{|i| i['reading']}.join(', ')
  end
end

