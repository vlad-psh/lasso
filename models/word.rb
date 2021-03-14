require_relative './progressable.rb'

class Word < ActiveRecord::Base
  has_many :wk_words, primary_key: :seq, foreign_key: :seq
  has_many :word_titles, primary_key: :seq, foreign_key: :seq
  has_many :progresses, primary_key: :seq, foreign_key: :seq
  has_many :word_details, primary_key: :seq, foreign_key: :seq

  has_many :sentences_words, primary_key: :seq, foreign_key: :word_seq
  has_many :sentences, through: :sentences_words

  include Progressable

  scope :by_kreb, ->(kreb) {joins(:word_titles).merge(WordTitle.where(title: kreb))}

  def krebs # All keb's and reb's
    return [*kebs, *rebs].compact
  end

  def burn_by!(user)
    progress = Progress.find_or_create_by(seq: self.seq, user: user)
    throw StandardError.new("Already burned") if progress.burned_at

    progress.burned_at = DateTime.now
    progress.save

    return true
  end

  def list_title
    self.kebs ? self.kebs[0] : self.rebs[0]
  end

  def list_desc
    meaning = self.en[0]['gloss'][0]
    meaning.length > 25 ? meaning = meaning[0..20] + '...' : meaning
  end

  def kreb_min_length
    rebs.present? ? rebs.map{|i|i.length}.min : 100
  end

  def meikyo_mecab
    return nil if read_attribute(:meikyo).blank?

    cache_key = "w/#{seq}/v2"
    cache = MecabCache.find_by(key: cache_key)
    return cache.data if cache.present? && cache.data

    plain = meikyo
    data = [{
      gloss: plain[0][:gloss].map{|i| mecab_light(i)}
    }]
    MecabCache.create(key: cache_key, data: data)
    data
  end

  def meikyo
    return nil if read_attribute(:meikyo).blank?

    glosses = read_attribute(:meikyo).map do |sense|
      sense['gloss'].map{|gloss| gloss.split("\n")}
    end.flatten

    [{gloss: glosses}]
  end

  private
  def mecab_light(str)
    mecab_parse(str).each_with_object([]) do |i,a|
      if i[:seq].blank? && a.last && a.last[:seq].blank?
        a[a.length - 1][:text] += i[:text]
      else
        a << i.slice(:text, :seq, :base)
      end
    end
  end
end

