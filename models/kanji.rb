class Kanji < ActiveRecord::Base
  self.table_name = 'kanji'
  has_many :kanji_properties
  has_many :progresses

  def self.with_progresses(user)
    elements = all
    progresses = Progress.joins(:kanji).where(user: user).merge(elements).hash_me(:kanji_id)
    elements.each do |e|
      e.user_progresses = progresses[e.id]
    end
  end

  def user_progresses=(value)
    @_user_progresses = value
  end

  def user_progresses
    return @_user_progresses if defined?(@_user_progresses)
    throw StandardError.new("'user_progresses' property can be accessed only when elements have been selected with 'with_progresses' method")
  end
end

