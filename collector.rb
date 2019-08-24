class Collector
  def initialize(user, opts = {})
    @words = Word.none
    @kanjis = Kanji.none
    @radicals = WkRadical.none

    raise ArgumentError.new("User expected as first param") unless user.kind_of?(User)
    @user = user
    @progresses = nil

    @words    = opts[:words]    if opts[:words]    &&    opts[:words].kind_of?(ActiveRecord::Relation)
    @kanjis   = opts[:kanjis]   if opts[:kanjis]   &&   opts[:kanjis].kind_of?(ActiveRecord::Relation)
    @radicals = opts[:radicals] if opts[:radicals] && opts[:radicals].kind_of?(ActiveRecord::Relation)

    @need_kanji_summary = opts[:radicals] && opts[:radicals].kind_of?(ActiveRecord::Relation) ? true : false
    @include_drills = opts[:words] && opts[:words].kind_of?(ActiveRecord::Relation) ? true : false
  end

  def to_json
    return to_hash.to_json
  end

  def to_hash
    # Add 'includes' directive to final relation
    @words = @words.includes(:wk_words, :word_titles)
    @word_details = WordDetail.where(word: @words, user: @user)

    kanji_chars = @words.map{|i| i.kanji.try(:split, '') || []}.flatten.uniq
    @kanjis = @kanjis.or(Kanji.where(title: kanji_chars))
                     .includes(wk_kanji: :wk_radicals)

    radical_ids = @kanjis.map{|i| i.wk_kanji.try(:wk_radicals).try(:map, &:id) || []}.flatten.uniq
    @radicals = @radicals.or(WkRadical.where(id: radical_ids))
              .includes(:wk_kanji_radicals)

    wk_kanji_ids = @need_kanji_summary ? @radicals.map{|i| i.wk_kanji_radicals.map(&:wk_kanji_id) }.flatten.uniq : []
    kanji_summary = WkKanji.where(id: wk_kanji_ids)
                .select(:id, :title, :meaning, :kanji_id)

    @progresses = Progress.where(user: @user, seq: @words.map(&:seq))
              .or(Progress.where(user: @user, kanji_id: @kanjis.map(&:id)))
              .or(Progress.where(user: @user, wk_radical_id: @radicals.map(&:id)))
              .or(Progress.where(user: @user, kanji_id: kanji_summary.map(&:kanji_id)))
              .includes(:drills)

    drills = @include_drills ? Drill.where(user: @user) : Drill.none

    return {
      words: @words.map{|i| word_structure(i)},
      kanjis: @kanjis.map{|i| kanji_structure(i)},
      radicals: @radicals.map{|i| radical_structure(i)},
      kanji_summary: kanji_summary.map{|i| kanji_summary_structure(i)},
      drills: drills.map{|i| {id: i.id, title: i.title, is_active: i.is_active} },
      paths: {
        learn:   path_to(:api_learn),
        burn:    path_to(:api_burn),
        flag:    path_to(:api_flag),
        comment: path_to(:api_word_comment),
        drill:   path_to(:drill_add_word),
        autocomplete: path_to(:api_word_autocomplete)
      }
    }
  end

  def path_to(path_name)
    # Modified fragment of sinatra-snap code
    pattern = Sinatra::Application.named_paths[path_name]
    raise ArgumentError.new("Unknown path ':#{path_name.to_s}'") if pattern == nil
    pattern.extend(Sinatra::UrlBuilder)
  end

  def word_structure(w)
    result = w.serializable_hash(only: [:seq, :jlptn, :nf, :en, :ru])
    result[:comment] = @word_details.detect{|i| i.seq == w.seq}.try(:comment)

    result[:krebs] = w.word_titles.sort{|a,b| a.id <=> b.id}.map do |t|
      k = {title: t.title, is_common: t.is_common}
      kreb_progress = @progresses.detect{|p| p.title == t.title && p.seq == w.seq}
      k[:progress] = kreb_progress.present? ? kreb_progress.api_hash : {}
      k[:drills] = kreb_progress.present? ? kreb_progress.drills.map(&:id) : []
      k
    end

##    all_sentences = Sentence.joins(:sentences_words).merge(SentencesWord.where(word_seq: [seq, *long_words.pluck(:seq)]))
##    result[:sentences] = all_sentences.map{|i| {jp: i.japanese, en: i.english, href: path_to(:sentence).with(i.id)}}

    return result.merge({
      sentences: [], # Empty placeholder
      cards: w.wk_words.sort{|a,b| a.level <=> b.level}.map{|c|
        {
          title: c.title,
          level: c.level,
          reading: c.reading,
          meaning: c.meaning,
          pos:   c.pos,
          mmne:  c.mmne,
          rmne:  c.rmne,
          sentences: c.sentences
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
        wk_meaning: w.meaning,
        wk_readings: w.readings.select{|i| i['primary'] == true}.map{|i| i['reading']},
        radicals: k.wk_kanji.wk_radicals.map(&:id),
        url: path_to(:kanji).with(k.id)
      })
    end

    result[:progress] = @progresses.detect{|p| p.kanji_id == k.id}.try(:api_hash) || {}
    return result
  end

  def kanji_summary_structure(k)
    return {
      wk_id: k.id,
      title: k.title,
      meaning: k.meaning.split(',').first,
      href: path_to(:kanji).with(k.kanji_id),
      progress: @progresses.detect{|p| p.kanji_id == k.kanji_id}.try(:api_hash) || {}
    }
  end

  def radical_structure(r)
    result = r.serializable_hash(only: [:id, :title, :level, :meaning, :nmne, :svg])
    result[:kanji_ids] = r.wk_kanji_radicals.map(&:wk_kanji_id)
    result[:progress] = @progresses.detect{|p| p.wk_radical_id == r.id}.try(:api_hash) || {}
    result[:href] = path_to(:wk_radical).with(r.id)
    return result
  end
end
