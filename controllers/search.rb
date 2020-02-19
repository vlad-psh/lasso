path search_old: '/search_old',
     search: '/search'

get :search_old do
  protect!

  @words = []
  @kanji = []
  @radicals = []
  @russian_words = RussianWord.none
  q = params['query'].strip
  @title = "🔎 #{q}"

  if q.present?
    if params[:japanese].present?
      q_hiragana = q.downcase.hiragana

      @words = Word.where('searchable_jp LIKE ? OR searchable_jp LIKE ?', "%#{q}%", "%#{q_hiragana}%").order(:is_common, :id).limit(1000).with_progresses(current_user).sort{|a,b| a.kreb_min_length <=> b.kreb_min_length}
      @kanji = Kanji.where('kanji.title LIKE ?', q).order(:grade).with_progresses(current_user)
    else
      if q.length > 1
        @russian_words = RussianWord.where("title ILIKE ?", "#{q}%").order(id: :asc)
      end

      @words = Word.where('searchable_en ILIKE ? OR searchable_ru ILIKE ?', "%#{q}%", "%#{q}%").order(:is_common, :id).limit(1000).with_progresses(current_user).sort{|a,b| a.kreb_min_length <=> b.kreb_min_length}
      @kanji = Kanji.where('searchable_en ILIKE ?', "%#{q}%").order(:grade).with_progresses(current_user)
      @radicals = WkRadical.where('meaning ILIKE ?', "%#{q}%").order(:level).with_progresses(current_user)
    end
  end

  slim :search_old
end

get :search do
  protect!
  slim :search
end

post :search do
  protect!

  q = params['query'].strip.downcase
  return if q.blank?

  if q.length == 1 && q.kanji? # this condition shoud be before 'fwd search' condition
    return search_kanji(q)
  elsif q.hiragana.japanese? # any russian words is detected as japanese, lol
    return search_fwd(q)
  else
    return search_english(q)
  end
end

def search_fwd(q)
  qk = q.katakana
  q = q.hiragana unless q.japanese?

  # Kinda simple deflector
  if q =~ /(って|った)$/
    base = q.gsub(/(って|った)$/, '')
    qstr = "(#{q}%|#{base}う|#{base}つ|#{base}る)"
  elsif q =~ /(んで|んだ)$/
    base = q.gsub(/(んで|んだ)$/, '')
    qstr = "(#{q}%|#{base}ぬ|#{base}む|#{base}ぶ)"
  elsif q =~ /(いて|いた)$/
    base = q.gsub(/(いて|いた)$/, '')
    qstr = "(#{q}%|#{base}く)"
  elsif q =~ /(いで|いだ)$/
    base = q.gsub(/(いで|いだ)$/, '')
    qstr = "(#{q}%|#{base}ぐ)"
  else
    qstr = "(#{q}|#{qk})%"
  end

  word_titles = WordTitle.includes(:word).where("title SIMILAR TO ?", qstr).order(nf: :asc, id: :asc).limit(1000).sort do |a,b|
    if a.is_common != b.is_common
      a.is_common == true ? -1 : 1 # common words should be first
    elsif (compare = a.title.length <=> b.title.length) != 0
      compare # result of comparing lengths
    else
      a.title <=> b.title # result of comparing two strings
    end
  end

  seqs = word_titles.map{|i|i.seq}.uniq
  return search_result_from_seqs(seqs).to_json
end

def search_result_from_seqs(seqs, word_titles = nil)
  progresses = Progress.where(user: current_user, seq: seqs).where.not(learned_at: nil).pluck(:seq)
  word_titles = WordTitle.eager_load(:word).where(seq: seqs).order(order: :asc) unless word_titles.present?

  result = seqs.map do |seq|
    wts = word_titles.filter{|w| w.seq == seq}
    title = wts.first.word.list_title
    [
      seq,
      title,
      wts.filter{|w| w.is_kanji == false && w.title != title}.first.try(:title),
      wts.first.word.en[0]['gloss'].join(', '),
      wts.first.is_common, # If there is more than one WordTitle, show property for 'best match' (ie. common, shortest)
      progresses.include?(seq)
    ]
  end

  return result
end

def search_kanji(q)
# TODO: Limit search results
  seqs1 = Progress.words.where(user: current_user).where('title LIKE ?', "%#{q}%").pluck(:seq)
  seqs2 = WordTitle.where(is_kanji: true).where('title LIKE ?', "%#{q}%").order(is_common: :desc, nf: :asc).limit(500).sort do |a,b|
    if a.is_common != b.is_common
      a.is_common == true ? -1 : 1 # common words should be first
    elsif (compare = a.title.length <=> b.title.length) != 0
      compare # result of comparing lengths
    else
      a.title <=> b.title # result of comparing two strings
    end
  end.map {|i| i.seq}

  return search_result_from_seqs(seqs1 | seqs2).to_json
end

def search_english(q)
  q = q.gsub(/\.$/, '')
  seqs = Word.where('searchable_en ILIKE ? OR searchable_ru ILIKE ?', "%#{q}%", "%#{q}%").order(:is_common, :id).limit(1000).map{|i| i.seq} # .sort{|a,b| a.kreb_min_length <=> b.kreb_min_length}

  return search_result_from_seqs(seqs).to_json
end
