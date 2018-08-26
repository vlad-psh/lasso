class Card < ActiveRecord::Base
  has_many :actions
  has_many :progresses
  # low-level:
  has_many :cards_relations
  has_many :inverse_cards_relations, class_name: 'CardsRelation', foreign_key: :relation_id
  # high-level:
  has_many :relations, through: :cards_relations
  has_many :inverse_relations, through: :inverse_cards_relations, source: :card
  belongs_to :word, primary_key: :seq, foreign_key: :seq

  def self.with_progress(user)
    progresses = Progress.joins(:card).merge( all.unscope(:select) ).where(user: user).hash_me
    all.each do |c|
      c.progress = progresses[c.id]
    end
  end

  def progress=(value)
    @_progress = value
  end

  def progress
    return @_progress if defined?(@_progress)
    throw StandardError.new("'progress' property can be accessed only when elements have been selected with 'with_progress' method")
  end

# =====================================
# OBJECT

  scope :radicals, ->{where(element_type: 'r')}
  scope :kanjis,   ->{where(element_type: 'k')}
  scope :words,    ->{where(element_type: 'w')}

  def radicals
    raise StandardError("Unknown method for type #{self.element_type}") unless self.element_type == 'k'
    self.relations.where(element_type: 'r')
  end

  def words
    raise StandardError("Unknown method for type #{self.element_type}") unless self.element_type == 'k'
    self.relations.where(element_type: 'w')
  end

  def kanjis
    raise StandardError("Unknown method for type #{self.element_type}") if self.element_type == 'k'
    return self.inverse_relations
  end

  def same_type
    return case element_type
        when 'r' then Card.radicals
        when 'k' then Card.kanjis
        when 'w' then Card.words
        else nil
    end
  end

  def radical?
    element_type == 'r' ? true : false
  end

  def kanji?
    element_type == 'k' ? true : false
  end

  def word?
    element_type == 'w' ? true : false
  end

  def tplural
    return INFODIC[element_type.to_sym][:plural]
  end

  def tsingular
    return INFODIC[element_type.to_sym][:singular]
  end

  def description
    if element_type == 'k'
      return detailsb['yomi'][detailsb['yomi']['emph']]
    else
      return detailsb['en'].first
    end
  end

  def pitch_str
    throw StandardError.new("Card##{self.id} is not a word") unless self.word?

    return '?' unless self.detailsb['pitch']
    pitches = []
    self.detailsb['pitch'].each do |reading,pitch|
      pitches << pitch if self.detailsb['readings'].include?(reading)
    end
    return pitches.flatten.join(', ')
  end

  def pitch_detailed_str
    throw StandardError.new("Card##{self.id} is not a word") unless self.word?

    return 'nil' unless self.detailsb['pitch']
    return self.detailsb['pitch'].to_s
  end

  def unlock_by!(user)
    progress = Progress.find_or_create_by(card: self, user: user)
    progress.update_attribute(:seq, self.seq)

    unless progress.unlocked
      progress.unlocked = true
      progress.unlocked_at = DateTime.now
      progress.save
      Action.create(card: self, progress: progress, ueser: user, action_type: 'unlocked')
    end
  end

  def learn_by!(user)
    progress = Progress.find_by(card: self, user: user)
    throw StandardError.new("Card info not found") unless progress.present?
    throw StandardError.new("Already learned") if progress.learned

    progress.learned = true
    progress.learned_at = DateTime.now
    progress.deck = 0
    progress.seq = self.seq
    progress.save

    Action.create(card: self, progress: progress, user: user, action_type: 'learned')

    stats = Statistic.find_or_initialize_by(user: user, date: Date.today)
    stats.learned[self.element_type] += 1
    stats.save

    new_elements = []
    # Unlock linked elements (kanjis for radicals; words for kanjis)
    if self.radical?
      self.kanjis.each do |k|
        begin
          # check if all radicals are already unlocked
          k.radicals.with_progress(user).each {|r| throw StandardError.new('Will not be unlocked') unless r.progress.learned }
          k.unlock_by!(user)
          new_elements << k
        rescue
          next
        end
      end
    elsif self.kanji?
      self.words.each do |w|
        begin
          w.kanjis.with_progress(user).each {|k| throw StandardError.new('Will not be unlocked') unless k.progress.learned }
          w.unlock_by!(user)
          new_elements << w
        rescue
          next
        end
      end
    end

    # Unlock radicals for next level if there was last learned card in current level
    new_current_level = user.current_level
    if (self.level < new_current_level)
      Card.radicals.where(level: new_current_level).with_progress(user).each do |r|
        unless (r.progress && r.progress.unlocked)
          r.unlock_by!(user)
          new_elements << r
        end
      end
      # ... and add new Action, showing that we are completed another level
      Action.create(card: self, user: user, action_type: 'levelup')
    end

    return new_elements
  end

  def download_audio!
    until try_download("http://speech.fc:53000/?v=VW%20Show&t=#{URI::encode(self.title)}", "public/audio/#{self.id}.mp3") do true end
    self.detailsb['sentences'].each_with_index do |sentence, i|
      until try_download("http://speech.fc:53000/?v=VW%20Show&t=#{URI::encode(sentence['ja'])}", "public/audio/s#{self.id}_#{i}.mp3") do true end
    end if self.detailsb['sentences']
  end

  private
  def try_download(url, path)
    begin
      puts "Downloading #{url}"
      File.open(path, "w") do |f|
        IO.copy_stream(open(url), f)
      end
      return true
    rescue StandardError => e
      puts "Got an error: #{e.inspect}"
      puts "Sleeping for 1 second"
      sleep 1
      return false
    end
  end
end

