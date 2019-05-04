class WkKanjiRadical < ActiveRecord::Base
  belongs_to :wk_kanji
  belongs_to :wk_radical
end

class WkKanjiWord < ActiveRecord::Base
  belongs_to :wk_kanji
  belongs_to :wk_word
end
