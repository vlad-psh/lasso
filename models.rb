class Radical < ActiveRecord::Base
  has_and_belongs_to_many :kanjis
end

class Kanji < ActiveRecord::Base
  has_and_belongs_to_many :radicals
  has_and_belongs_to_many :words
end

class Word < ActiveRecord::Base
  has_and_belongs_to_many :kanjis
end
