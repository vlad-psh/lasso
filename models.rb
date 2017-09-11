class Radical < ActiveRecord::Base
  has_and_belongs_to_many :kanjis

  def description
    return self.en
  end

  def link
    path_to(:radical).with(description)
  end
end

class Kanji < ActiveRecord::Base
  has_and_belongs_to_many :radicals
  has_and_belongs_to_many :words

  def description
    return self.yomi[self.yomi['emph']].split(',')[0].strip
  end

  def link
    path_to(:kanji).with(self.title)
  end
end

class Word < ActiveRecord::Base
  has_and_belongs_to_many :kanjis

  def description
    return self.en.first
  end

  def link
    path_to(:word).with(self.id)
  end
end
