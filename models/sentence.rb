class Sentence < ActiveRecord::Base
  has_many :sentences_words, dependent: :destroy # Destroy only SentencesWords connection
  has_many :words, through: :sentences_words
  belongs_to :user
  belongs_to :drill
  has_many :sentence_reviews

  def swap_kanji_yomi
    self.structure = self.structure.map do |i|
      if i['seq'].present?
        yomi = i['reading']
        i['reading'] = i['text']
        i['text'] = yomi
      end
      i
    end
    self
  end
end

