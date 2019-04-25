class WkRadical < ActiveRecord::Base
  has_and_belongs_to_many :wk_kanji, through: :wk_kanji_radicals
  has_many :progresses

  def self.with_progresses(user)
    elements = all
    progresses = Progress.joins(:wk_radical).where(user: user).merge(elements).hash_me(:wk_radical_id)
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

  def description
    details['en'].first
  end

  def list_title
    return title
  end

  def list_desc
    return details['en'].first
  end
end

