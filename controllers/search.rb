path search: '/search',
     search2: '/search2'

get :search do
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

  slim :search
end

get :search2 do
  protect!
  slim :search2
end

post :search2 do
  protect!
  q = params['query'].strip

  # TODO: English/Russian search
  q = q.hiragana unless q.japanese?

  # Kinda simple deflector
  if q =~ /(って|った)$/
    base = q.gsub(/(って|った)$/, '')
    qstr = "(#{q}|#{base}う|#{base}つ|#{base}る)%"
  elsif q =~ /(んで|んだ)$/
    base = q.gsub(/(んで|んだ)$/, '')
    qstr = "(#{q}|#{base}ぬ|#{base}む|#{base}ぶ)%"
  elsif q =~ /(いて|いた)$/
    base = q.gsub(/(いて|いた)$/, '')
    qstr = "(#{q}|#{base}く)%"
  elsif q =~ /(いで|いだ)$/
    base = q.gsub(/(いで|いだ)$/, '')
    qstr = "(#{q}|#{base}ぐ)%"
  else
    qstr = "#{q}%"
  end


  word_titles = WordTitle.where("title SIMILAR TO ?", qstr).order(:is_common, :id).limit(1000).pluck(:seq, :title, :is_common).sort do |a,b|
    if a[2] != b[2]
      a[2] == true ? -1 : 1 # common words should be first
    elsif (compare = a[1].length <=> b[1].length) != 0
      compare # result of comparing lengths
    else
      a[1] <=> b[1] # result of comparing two strings
    end
  end

  progresses = Progress.where(user: current_user, seq: word_titles.map{|i|i[0]}).where.not(learned_at: nil).pluck(:seq)

  result = word_titles.map do |wt|
    [*wt, progresses.include?(wt[0]) ? true : false]
  end

  return result.to_json
end

