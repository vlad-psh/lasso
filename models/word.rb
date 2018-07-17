class Word < ActiveRecord::Base
  belongs_to :card
  has_and_belongs_to_many :sentences
  has_many :progresses, primary_key: :card_id, foreign_key: :card_id

  def self.with_progress(user)
    progresses = Progress.joins(:word).merge( all.unscope(:select) ).where(user: user).hash_me
    all.each do |c|
      c.progress = progresses[c.card_id]
    end
  end

  def progress=(value)
    @_progress = value
  end

  def progress
    return @_progress if defined?(@_progress)
    throw StandardError.new("'progress' property can be accessed only when elements have been selected with 'with_progress' method")
  end

  def krebs # All keb's and reb's
    kebs = kele ? kele.map{|i| i['keb']} : []
    rebs = rele ? rele.map{|i| i['reb']} : []
    return [*kebs, *rebs].compact
  end
end

