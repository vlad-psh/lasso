class Sentence < ActiveRecord::Base
  has_many :sentences_words, dependent: :destroy # Destroy only SentencesWords connection
  has_many :words, through: :sentences_words
  belongs_to :user
  belongs_to :drill
  has_many :sentence_reviews

  def study_hash(user)
    return {
      id: id,
      structure: structure,
      english: english,
      payload: Collector.new(user, words: Word.where(seq: structure.map{|i|i['seq']}.compact)).to_hash
    }
  end

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

  def highlight_word(seq)
    self.structure.each do |i|
      i['highlight'] = true if i['seq'] == seq
    end
  end
end

