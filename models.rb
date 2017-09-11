class Radical < ActiveRecord::Base
  has_and_belongs_to_many :kanjis

  def description
    return self.en
  end

  def link_params
    return {resource: :radical, id: self.description}
  end
end

class Kanji < ActiveRecord::Base
  has_and_belongs_to_many :radicals
  has_and_belongs_to_many :words
  include(Sinatra::PathBuilderSupport)

  def description
    return self.yomi[self.yomi['emph']].split(',')[0].strip
  end

  def link_params
    return {resource: :kanji, id: self.title}
  end
end

class Word < ActiveRecord::Base
  has_and_belongs_to_many :kanjis

  def description
    return self.en.first
  end

  def link_params
    return {resource: :word, id: self.id}
  end
end
