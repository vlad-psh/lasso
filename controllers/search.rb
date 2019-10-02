path search: '/search'

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

