require 'mecab/light'

path mecab: '/mecab'

def mecab_parse(sentence)
  tagger = MeCab::Light::Tagger.new('')
  mecab_result = tagger.parse(sentence)
#  result.map(&:surface)
  result = []
  mecab_result.each do |e|
    feature = e.feature.split(',')
    result << {
      text: e.surface,
      reading: feature[7].try(:hiragana),
      base: feature[6]
    }
  end

  word_titles = WordTitle.where(title: result.map{|i|i[:base]}).uniq
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
      seqs = WordTitle.where(title: e[:reading], seq: seqs).pluck(:seq).uniq
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

