class WkRadical < ActiveRecord::Base
  has_and_belongs_to_many :wk_kanji, through: :wk_kanji_radicals
  has_many :progresses

  def self.with_progress(user)
    elements = all
    progresses = Progress.joins(:wk_radical).where(user: user).merge(elements).hash_me(:wk_radical_id)
    elements.each do |e|
      # radicals has only one progress per user
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
    return title
  end

  def list_desc
    meaning.try(:gsub, /,.*/, '')
  end
end

