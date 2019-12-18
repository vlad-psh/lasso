class Picture < ActiveRecord::Base
  belongs_to :user

  def self.random_sid
    range = [*'a'..'z', *'A'..'Z', *'0'..'9']
    while Picture.where(sid: ( _sid = (0...8).map{range.sample}.join )).present? do end
    return _sid
  end

  def create_sid
    self.sid = Picture.random_sid unless self.sid
  end

  def filepath(type)
    type = type.to_s if type.is_a?(Symbol)
    File.join($config['pictures'], type, self.sid)
  end

end
