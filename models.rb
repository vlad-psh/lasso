module WKElementInstance
  def unlock!
    unless self.unlocked_at
      self.unlocked_at = DateTime.now
      self.save
    end
  end

  def learned?
    return self.learned_at ? true : false
  end

  def element_type
    return self.model_name.singular.to_sym
  end
end

module WKElement
  def failed
    # 'learned_at != nil' automatically because of 'fails != 0'
    self.where(deck: 0).where.not(fails: 0)
  end

  def expired
    # 'learned_at != nil' automatically because of 'deck != 0' and 'scheduled != nil'
    self.where(scheduled: Date.new..Date.today).where.not(deck: 0)
  end

  def just_learned
    self.where(deck: 0, fails: 0).where.not(learned_at: nil)
  end

  def just_unlocked
    self.where(learned_at: nil).where.not(unlocked_at: nil)
  end
end

class Radical < ActiveRecord::Base
  has_and_belongs_to_many :kanjis
  include WKElementInstance
  extend WKElement

  def description
    return self.en
  end

  def link_params
    return {resource: :radical, id: self.description}
  end

  def learn!
    unless learned?
      self.learned_at = DateTime.now
      self.save
    end

    new_elements = []
    self.kanjis.each do |k|
      unlock = true
      k.radicals.each do |r|
        unlock = false unless r.learned?
      end
      if unlock
        k.unlock!
        new_elements << k.title
      end
    end
    return new_elements
  end
end

class Kanji < ActiveRecord::Base
  has_and_belongs_to_many :radicals
  has_and_belongs_to_many :words
  include WKElementInstance
  extend WKElement

  def description
    return self.yomi[self.yomi['emph']].split(',')[0].strip
  end

  def link_params
    return {resource: :kanji, id: self.title}
  end

  def learn!
    unless learned?
      self.learned_at = DateTime.now
      self.save
    end

    new_elements = []
    self.words.each do |w|
      unlock = true
      w.kanjis.each do |k|
        unlock = false unless k.learned?
      end
      if unlock
        w.unlock!
        new_elements << w.title
      end
    end
    return new_elements
  end
end

class Word < ActiveRecord::Base
  has_and_belongs_to_many :kanjis
  include WKElementInstance
  extend WKElement

  def description
    return self.en.first
  end

  def link_params
    return {resource: :word, id: self.id}
  end

  def learn!
    unless learned?
      self.learned_at = DateTime.now
      self.save
    end

    return [] # no new elements learned
  end
end
