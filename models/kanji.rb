class Kanji < ActiveRecord::Base
  self.table_name = 'kanji'
  has_many :progresses
  has_one :wk_kanji

  def self.with_progresses(user)
    elements = all
    progresses = Progress.joins(:kanji).where(user: user).merge(elements).hash_me(:kanji_id)
    elements.each do |e|
      # kanji has only one progress per user
      e.user_progress = progresses[e.id].try(:first)
    end
  end

  def user_progress=(value)
    @_user_progress = value
  end

  def user_progress
    return @_user_progress if defined?(@_user_progress)
    throw StandardError.new("'user_progress' property can be accessed only when elements have been selected with 'with_progresses' method")
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

