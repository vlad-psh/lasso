class User < ActiveRecord::Base
  has_many :activities, dependent: :destroy
  has_many :drills, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :progresses, dependent: :destroy
  has_many :sentences, dependent: :destroy
  has_many :sentence_reviews, dependent: :destroy
  has_many :srs_progresses, dependent: :destroy
  has_many :statistics, dependent: :destroy
  has_many :word_details, dependent: :destroy

  def password=(pwd)
    self.salt = SecureRandom.hex
    self.pwhash = Digest::SHA256.hexdigest(pwd + self.salt)
  end

  def check_password(pwd)
    return Digest::SHA256.hexdigest(pwd + self.salt) == self.pwhash
  end

  def to_h
    {id: id, login: login}
  end
end
