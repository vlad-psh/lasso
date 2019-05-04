class Collector
  def initialize(user, opts = {})
    @words = Word.none
    @kanjis = Kanji.none
    @radicals = WkRadical.none

    raise StandardError.new("User expected as first param") unless user.kind_of?(User)
    @user = user
    @progresses = nil

    @words    = opts[:words]    if opts[:words]    &&    opts[:words].kind_of?(ActiveRecord::Relation)
    @kanjis   = opts[:kanjis]   if opts[:kanjis]   &&   opts[:kanjis].kind_of?(ActiveRecord::Relation)
    @radicals = opts[:radicals] if opts[:radicals] && opts[:radicals].kind_of?(ActiveRecord::Relation)
  end

  def to_json
    return to_hash.to_json
  end

  def to_hash
    # Add 'includes' directive to final relation
    @words = @words.includes(:short_words, :long_words, :wk_words, :word_titles)
    @word_details = WordDetail.where(word: @words, user: @user)

    kanji_chars = @words.map{|i| i.kanji.try(:split, '') || []}.flatten.uniq
    @kanjis = @kanjis.or(Kanji.where(title: kanji_chars))
                     .includes(wk_kanji: :wk_radicals)

    @progresses = Progress.where(user: @user, seq: @words.map(&:seq))
              .or(Progress.where(user: @user, kanji_id: @kanjis.map(&:id)))

    return {
      words: @words.map{|i| word_structure(i)},
      kanjis: @kanjis.map{|i| kanji_structure(i)},
      paths: {
        learn:   path_to(:api_word_learn),
        burn:    path_to(:api_word_burn),
        flag:    path_to(:api_word_flag),
        comment: path_to(:api_word_comment),
        connect: path_to(:api_word_connect),
        drill:   path_to(:drill_add_word),
        autocomplete: path_to(:api_word_autocomplete)
      }
    }
  end

  def path_to(path_name)
    pattern = Sinatra::Application.named_paths[path_name]
    raise ArgumentError.new("Unknown path ':#{path_name.to_s}'") if pattern == nil
    pattern.extend(Sinatra::UrlBuilder)
  end

  def word_structure(w)
    result = w.serializable_hash(only: [:seq, :jlptn, :nf, :en, :ru])
    result[:comment] = @word_details.detect{|i| i.seq == w.seq}.try(:comment)

    result[:krebs] = w.word_titles.sort{|a,b| a.id <=> b.id}.map do |t|
      {
        title: t.title,
        is_common: t.is_common,
        progress: @progresses.detect{|p| p.title == t.title && p.seq == w.seq}.try(:api_hash) || {}
      }
    end

##    result[:sentences] = word.all_sentences.map{|i| {jp: i.japanese, en: i.english, href: path_to(:sentence).with(i.id)}}
##    rawSentences = Sentence.where(structure: nil).where('japanese ~ ?', word.krebs.join('|')) # possible sentences
##    result[:rawSentences] = rawSentences.map{|i| {jp: i.japanese, en: i.english, href: path_to(:sentence).with(i.id)}}

    return result.merge({
      sentences: [], rawSentences: [], # # Empty placeholders
      shortWords: w.short_words.map{|i| {seq: i.seq, title: i.krebs[0], href: path_to(:word).with(i.seq)}},
      longWords:  w.long_words.map{|i| {seq: i.seq, title: i.krebs[0], href: path_to(:word).with(i.seq)}},
      cards: w.wk_words.sort{|a,b| a.level <=> b.level}.map{|c|
        {
          title: c.title,
          level: c.level,
          reading: c.reading,
          meaning: c.meaning,
          pos:   c.pos,
          mmne:  c.mmne,
          rmne:  c.rmne
        }
      }
    })
  end

  def kanji_structure(k)
    result = k.serializable_hash(only: [:id, :title, :jlptn, :english, :on, :kun])

    if (w = k.wk_kanji).present?
      result = result.merge({
        wk_level: w.level,
        mmne: w.mmne,
        mhnt: w.mhnt,
        rmne: w.rmne,
        rhnt: w.rhnt,
        radicals: k.wk_kanji.wk_radicals.map(&:id)
      })
    end

    result[:progress] = @progresses.detect{|p| p.kanji_id == k.id}.try(:api_hash) || {}
    return result
  end

  def radical_structure(r)
    result = radical.serializable_hash(only: [:title, :level, :meaning, :nmne, :svg])
    result[:progress] = @progresses.detect{|p| p.wk_radical_id == r.id}.try(:api_hash) || {}
    return result
  end
end
