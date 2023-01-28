paths dashboard: '/dashboard',
    list_level: '/level/:level',
    list_nf: '/words/:nf',
    list_jlpt_words: '/words/jlpt/:level',
    list_jlpt_kanji: '/kanji/jlpt/:level'

get :dashboard do
  @view_user = current_user || User.first

  @counters = {}

  k_jlpt = Kanji.joins(:progresses).merge( Progress.learned.kanjis.where(user: @view_user) ).group(:jlptn).count
  # {"5"=>103, "4"=>181, "3"=>367, "2"=>400, "1"=>1207} # non-cumulative
  # {"5"=>103, "4"=>284, "3"=>651, "2"=>1051, "1"=>2258} # cumulative
  k_total = {"5"=>103, "4"=>284, "3"=>651, "2"=>1051, "1"=>2258}
  cumulative = 0
  %w(5 4 3 2 1).each do |lvl|
    cumulative += k_jlpt[lvl.to_i] || 0
    @counters["n#{lvl}".to_sym] = {'k' => (100.0*cumulative/k_total[lvl]).round}
  end

  w_jlpt = Word.joins(:progresses).merge( Progress.learned.words.where(user: @view_user) ).group(:jlptn).count
  # {"5"=>438, "4"=>416, "3"=>964, "2"=>531, "1"=>681} # word cards in WK db + 3284 of unknown level
  # {"5"=>438, "4"=>854, "3"=>1818, "2"=>2349, "1"=>3030} # same as above but cumulative

  # 1=>2470, 2=>1603, 3=>1824, 4=>582, 5=>593 # words in db
  # {"5"=>593, "4"=>1175, "3"=>2999, "2"=>4602, "1"=>7072} same, but cumulative

  # {"5"=>602, "4"=>595, "3"=>2165, "2"=>3249, "1"=>2708} # real life total counts
  # {"5"=>602, "4"=>1197, "3"=>3362, "2"=>6611, "1"=>9319} # same as above but cumulative
  w_total = {"5"=>593, "4"=>1175, "3"=>2999, "2"=>4602, "1"=>7072}
  cumulative = 0
  %w(5 4 3 2 1).each do |lvl|
    cumulative += w_jlpt[lvl.to_i] || 0
    @counters["n#{lvl}".to_sym] ||= {}
    @counters["n#{lvl}".to_sym]['w'] = (100.0*cumulative/w_total[lvl]).round
  end

  slim :dashboard
end

get :list_level do
  @view_user = current_user || User.first

  lvl = params[:level].to_i
  @pagination = {current: "Level&nbsp;#{lvl}"}
  @pagination[:prev] = {href: path_to(:list_level).with(lvl - 1), title: "Level&nbsp;#{lvl - 1}"} if lvl > 1
  @pagination[:next] = {href: path_to(:list_level).with(lvl + 1), title: "Level&nbsp;#{lvl + 1}"} if lvl < 60

  @words = Word.joins(:wk_words).merge(WkWord.where(level: params[:level])).order(:id).as_for(@view_user)
#  @kanji = WkKanji.where(level: params[:level]).order(id: :asc).as_for(@view_user)
  @kanji = Kanji.includes(:wk_kanji).joins(:wk_kanji).merge(WkKanji.where(level: params[:level])).order(:id).as_for(@view_user)
  @radicals = WkRadical.where(level: params[:level]).order(id: :asc).as_for(@view_user)

  @title = "L.#{params[:level]}"
  @separate_list = true

  slim :list_level
end

get :list_nf do
  protect!

  lvl = params[:nf].to_i
  @pagination = {current: "NF&nbsp;##{lvl}"}
  @pagination[:prev] = {href: path_to(:list_nf).with(lvl - 1), title: "NF&nbsp;##{lvl - 1}"} if lvl > 1
  @pagination[:next] = {href: path_to(:list_nf).with(lvl + 1), title: "NF&nbsp;##{lvl + 1}"} if lvl < 48

  @elements = Word.where(nf: params[:nf]).order(:seq).as_for(current_user)

  slim :list
end

get :list_jlpt_words do
  @view_user = current_user || User.first

  lvl = params[:level].to_i
  @pagination = {current: "JLPT&nbsp;N#{lvl}"}
  @pagination[:prev] = {href: path_to(:list_jlpt_words).with(lvl + 1), title: "JLPT&nbsp;N#{lvl + 1}"} if lvl < 5
  @pagination[:next] = {href: path_to(:list_jlpt_words).with(lvl - 1), title: "JLPT&nbsp;N#{lvl - 1}"} if lvl > 1

  @elements = Word.where(jlptn: params[:level]).order(:id).as_for(@view_user)
  slim :list
end

get :list_jlpt_kanji do
  @view_user = current_user || User.first

  lvl = params[:level].to_i
  @pagination = {current: "JLPT&nbsp;N#{lvl}"}
  @pagination[:prev] = {href: path_to(:list_jlpt_kanji).with(lvl + 1), title: "JLPT&nbsp;N#{lvl + 1}"} if lvl < 5
  @pagination[:next] = {href: path_to(:list_jlpt_kanji).with(lvl - 1), title: "JLPT&nbsp;N#{lvl - 1}"} if lvl > 1

  @elements = Kanji.where(jlptn: params[:level]).order(:id).as_for(@view_user)
  slim :list
end

