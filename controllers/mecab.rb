require 'mecab/light'

path mecab: '/mecab'

def split_okurigana(word)
  base = ''
  okurigana = ''
  still_okurigana = true
  word.reverse.split('').each do |c|
    (c.hiragana? ? okurigana += c : still_okurigana = false) if still_okurigana
    base += c if still_okurigana == false
  end
  return [base.reverse, okurigana.reverse]
end

def base_reading(element)
  base_split = split_okurigana(element[:base])
  text_split = split_okurigana(element[:text])
  reading = element[:reading].gsub(/#{text_split[1]}$/, '') # subtract okurigana from reading
  return "#{reading}#{base_split[1]}" # append okurigana from base
end

def ignore_word(feature)
  return true if feature[0] == '記号'
  return true if %w(連体化 格助詞 接続助詞).include?(feature[1])
  return true if feature[4] =~ /特殊/
  return false
end

def mecab_parse(sentence)
  tagger = MeCab::Light::Tagger.new('')
  mecab_result = tagger.parse(sentence)
#  result.map(&:surface)
  result = []
  mecab_result.each do |e|
    feature = e.feature.split(',')
    #puts "------------- #{feature.inspect}"
    if ignore_word(feature)
      result << {text: e.surface}
    else
      result << {
        text: e.surface,
        reading: feature[7].try(:hiragana),
        base: feature[6]
      }
    end
  end

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

post :mecab do
  protect!

  wt = WordTitle.where(title: params[:sentence]).pluck(:seq).uniq

  if wt.length == 1 # found exact word
    w = Word.find_by(seq: wt[0])
    return [{
        text: params[:sentence],
        reading: w.rebs[0],
        base: params[:sentence],
        gloss: w.en[0]['gloss'][0],
        seq: wt[0]
    }].to_json
  else
    return mecab_parse(params[:sentence]).to_json
  end
end

