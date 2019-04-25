class Kanji < ActiveRecord::Base
  self.table_name = 'kanji'
  has_many :progresses
  has_one :wk_kanji

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

