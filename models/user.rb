class User < ActiveRecord::Base
  has_many :statistics
  has_many :notes
  has_many :progresses

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
