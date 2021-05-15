class MecabParser
  def self.light_parse(sentence)
    tagger = MeCab::Light::Tagger.new('')
    mecab_result = tagger.parse(sentence)
    # result.map(&:surface)
    result = []
    mecab_result.each do |e|
      feature = e.feature.split(',')
      # puts "------------- #{feature.inspect}"
      if ignore_word(e.surface, feature)
        result << {text: e.surface}
      else
        reading = feature[7].try(:hiragana)
        result << {
          text: e.surface,
          reading: reading,
          base: feature[6],
          base_reading: base_reading(e.surface, feature[6], reading),
        }
      end
    end

    # collapse text-only parts (without reading/base props) 
    result = result.each_with_object([]) do |i,a|
      if i[:reading].blank? && a.last && a.last[:reading].blank?
        a[a.length - 1][:text] += i[:text]
      else
        a << i
      end
    end

    return result
  end

  def self.parse(sentence)
    result = light_parse(sentence)
  
    word_titles_hash = {}
    WordTitle.where(title: result.map{|i|i[:base]}).uniq.each do |wt|
      word_titles_hash[wt.title] ||= []
      word_titles_hash[wt.title] << wt.seq
    end
  
    result.each do |e|
      seqs = word_titles_hash[e[:base]]
  
      if seqs.present? && seqs.length > 1
        # More than one results found (eg.: 石)
        # Find one with correct reading
        reading = base_reading(e)
        seqs = WordTitle.where(title: reading, seq: seqs).pluck(:seq).uniq
      end
  
      if seqs.blank? || seqs.length != 1 # Skip if length STILL > 1 (or == 0)
        e.delete(:reading)
        e.delete(:base)
        next
      end
  
      w = Word.find_by(seq: seqs.first)
      gloss = w.en[0]['gloss'][0]
      e[:gloss] = gloss.length > 25 ? gloss[0..20] + '...' : gloss
      e[:seq] = w.seq
    end
  
    return result
  end

  private
  def self.split_okurigana(word)
    base = ''
    okurigana = ''
    still_okurigana = true
    word.reverse.split('').each do |c|
      (c.hiragana? ? okurigana += c : still_okurigana = false) if still_okurigana
      base += c if still_okurigana == false
    end
    return [base.reverse, okurigana.reverse]
  end

  def self.base_reading(element)
    base_split = split_okurigana(element[:base])
    text_split = split_okurigana(element[:text])
    reading = element[:reading].gsub(/#{text_split[1]}$/, '') # subtract okurigana from reading
    return "#{reading}#{base_split[1]}" # append okurigana from base
  end

  def self.ignore_word(surface, feature)
    return true if %w(記号 助動詞 接頭詞).include?(feature[0])
    return true if %w(連体化 格助詞 接続助詞 終助詞).include?(feature[1])
    return true if feature[2] =~ /特殊/
    return true if feature[4] =~ /特殊/
    return true if %w(する *).include?(feature[6])
    return false
  end

  def self.base_reading(surface, base, reading)
    return reading if surface == base

    (0..(base.length-1)).each do |i|
      break reading.gsub(/#{surface[i..-1]}$/, base[i..-1]) if base[i] != surface[i]
    end
  end
end