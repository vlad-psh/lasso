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

    @progresses = Progress.where(user: @user).where(
                Progress.arel_table[:seq].in(@words.map(&:seq))
                .or(Progress.arel_table[:kanji_id].in(@kanjis.map(&:id)))
              ) #.eager_load(:drills)

    return {
      words: @words.map{|i| word_structure(i)},
      kanjis: @kanjis.map{|i| kanji_structure(i)},
    }
  end

  def path_to(path_name)
    # Modified fragment of sinatra-snap code
    pattern = Sinatra::Application.named_paths[path_name]
    raise ArgumentError.new("Unknown path ':#{path_name.to_s}'") if pattern == nil
    pattern.extend(Sinatra::UrlBuilder)
  end

  def word_structure(w)
    languages = [:en] | (@user.settings['lang'] || [])
    result = w.serializable_hash(only: languages | [:seq, :jlptn, :nf, :nhk_data, :kanji])
    result[:meikyo] = MecabParser.parse_definitions(w.meikyo) if w.meikyo.present?
    result[:comment] = @word_details.detect{|i| i.seq == w.seq}.try(:comment)

    result[:krebs] = w.word_titles.sort{|a,b| a.id <=> b.id}.map do |t|
      k = {title: t.title, is_common: t.is_common, is_kanji: t.is_kanji}
      k[:pitch] = t.pitch if t.pitch
      kreb_progress = @progresses.detect{|p| p.title == t.title && p.seq == w.seq}
      k[:progress] = kreb_progress.present? ? kreb_progress.api_hash : {}
      k[:drills] = kreb_progress.present? ? kreb_progress.drills.map(&:id) : []
      k
    end

##    all_sentences = Sentence.joins(:sentences_words).merge(SentencesWord.where(word_seq: [seq, *long_words.pluck(:seq)]))
##    result[:sentences] = all_sentences.map{|i| {jp: i.japanese, en: i.english, href: path_to(:sentence).with(i.id)}}

    return result.merge({
      cards: w.wk_words.sort{|a,b| a.level <=> b.level}.map{|c|
        {
          title: c.title,
          level: c.level,
          reading: c.reading,
          meaning: c.meaning,
          pos:   c.pos,
          mmne:  c.mmne,
          rmne:  c.rmne,
          sentences: c.sentences,
        }
      }
    })
  end

  def kanji_structure(k)
    result = k.serializable_hash(only: [:id, :title, :jlptn, :english, :on, :kun,
        :grade, :radnum, :links, :similars])
    result[:jp] = MecabParser.parse_definitions([k.jp]) if k.jp.present?
    result[:progress] = @progresses.detect{|p| p.kanji_id == k.id}.try(:api_hash) || {}
    return result
  end
end
