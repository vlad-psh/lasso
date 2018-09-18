require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'sinatra-snap'
require 'slim'

require 'rack-flash'
require 'yaml'
require 'redcloth'
#require 'httparty'
#require 'nokogiri'
require 'mojinizer'
require 'open-uri'
require 'mecab/light'

require_relative './helpers.rb'
Dir.glob('./models/*.rb').each {|model| require_relative model}

also_reload './helpers.rb'
also_reload './models/*.rb'

helpers WakameHelpers

paths index: '/',
    list_level: '/level/:level',
    list_nf: '/words/:nf',
    list_jlpt_words: '/words/jlpt/:level',
    list_jlpt_kanji: '/kanji/jlpt/:level',

    current: '/current', # get(redirection)
    cards: '/cards',
    learn: '/learn/:id', # post
    study: '/study/:class/:group', # get, post
    search: '/search', # post
    notes: '/notes',
    note: '/note/:id',
    login: '/login', # GET: login form; POST: log in
    logout: '/logout', # DELETE: logout
    settings: '/settings',
    word: '/word/:id',
    kanji: '/kanji/:id',
# Change word properties
    word_learn: '/word/learn', # POST
    word_burn: '/word/burn', # POST
    word_connect: '/word/connect',
    word_set_comment: '/word/:id/comment',
    word_flag: '/word/flag',
# Other API
    mecab: '/mecab',
    sentences: '/sentences', # POST
    sentence: '/sentence/:id', # DELETE
    autocomplete_word: '/autocomplete/word',
# Temporary API (should be deleted soon)
    study2: '/study2',
    wk_word: '/wk_word/:id',
    wk_kanji: '/wk_kanji/:id',
    wk_radical: '/wk_radical/:id'

configure do
  puts '---> init <---'

  $config = YAML.load(File.open('config/application.yml'))

  use Rack::Session::Cookie,
#        key: 'fcs.app',
#        domain: '172.16.0.11',
#        path: '/',
        expire_after: 2592000, # 30 days
        secret: $config['secret']

  use Rack::Flash

  DEGREES = ['快 Pleasant', '苦 Painful', '死 Death', '地獄 Hell', '天堂 Paradise', '現実 REALITY']
  INFODIC = {
    :r => {singular: :radical, plural: :radicals, japanese: '部首'},
    :k => {singular: :kanji, plural: :kanji, japanese: '漢字'},
    :w => {singular: :word, plural: :words, japanese: '言葉'}
  }
  SRS_RANGES = [[0, 0, 0], [2, 3, 4], [6, 7, 8], [12, 14, 16], [25, 30, 35], [50, 60, 70], [100, 120, 140], [200, 240, 280]]
end

get :index do
  @view_user = current_user || User.first

  @counters = {}

  [:just_learned, :expired, :any_learned].each do |g|
    @counters[g] = Progress.public_send(g).where(user: @view_user).group(:kind).count
  end

  k_jlpt = Kanji.joins(:progresses).merge( Progress.any_learned.where(user: @view_user, kind: :k) ).group(:jlptn).count
  # {"5"=>103, "4"=>181, "3"=>367, "2"=>400, "1"=>1207} # non-cumulative
  # {"5"=>103, "4"=>284, "3"=>651, "2"=>1051, "1"=>2258} # cumulative
  k_total = {"5"=>103, "4"=>284, "3"=>651, "2"=>1051, "1"=>2258}
  cumulative = 0
  %w(5 4 3 2 1).each do |lvl|
    cumulative += k_jlpt[lvl.to_i] || 0
    @counters["n#{lvl}".to_sym] = {'k' => (100.0*cumulative/k_total[lvl]).round}
  end

  w_jlpt = Word.joins(:progresses).merge( Progress.any_learned.where(user: @view_user, kind: :w) ).group(:jlptn).count
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

  slim :index
end

get :current do
  redirect path_to(:list_level).with(current_user.present? ? current_user.current_level : 1)
end

get :list_level do
  @view_user = current_user || User.first

  lvl = params[:level].to_i
  @pagination = {current: "Level&nbsp;#{lvl}"}
  @pagination[:prev] = {href: path_to(:list_level).with(lvl - 1), title: "Level&nbsp;#{lvl - 1}"} if lvl > 1
  @pagination[:next] = {href: path_to(:list_level).with(lvl + 1), title: "Level&nbsp;#{lvl + 1}"} if lvl < 60

  @words = WkWord.where(level: params[:level]).order(id: :asc).with_progresses(@view_user)
  @kanji = WkKanji.where(level: params[:level]).order(id: :asc).with_progresses(@view_user)
  @radicals = WkRadical.none

  @title = "L.#{params[:level]}"
  @separate_list = true

  slim :list_level
end

post :learn do
  protect!

  e = Card.find(params[:id])
  e.learn_by!(current_user)

  redirect path_to(:card).with(params[:id])
end

get :study do
  protect!

  progresses = Progress.public_send(safe_group(params[:group])).
                        public_send(safe_type(params[:class])).
                        where(user: current_user)
  @count = progresses.count
  @progress = progresses.order('RANDOM()').first

  if @progress.present?
    @title = @progress.title
    slim :study
  else
    flash[:notice] = "No more #{params[:class]} in \"#{params[:group]}\" group"
    redirect path_to(:index)
  end
end

post :study do
  protect!

  p = Progress.find(params[:id])
  halt(403, 'Forbidden') if p.user_id != current_user.id
  halt(400, 'Element not found') unless p.present?

  p.answer_by!(params[:answer], current_user)

  redirect path_to(:study).with(safe_type(params[:class]), safe_group(params[:group]))
end

get :search do
  protect!

  @words = Word.none
  @wk_words = WkWord.none
# TODO: Search by kanji/radicals/etc
  @russian_words = RussianWord.none
  q = params['query'].strip
  @title = "🔎 #{q}"

  if q.present?
    qj = q.downcase.hiragana

    if q.length > 1
      @wk_words = WkWord.where("title ILIKE ? OR details->>'en' ILIKE ? OR details->>'readings' LIKE ?", "%#{q}%", "%#{q}%", "%#{qj}%").order(level: :asc)
      @russian_words = RussianWord.where("title ILIKE ?", "#{q}%").order(id: :asc)
    else
      @wk_words = qj.japanese? ? WkWord.where("title ILIKE ? OR details->>'readings' LIKE ?", "%#{qj}%", "%#{qj}%").order(level: :asc) : WkWord.none
    end

    seqs = WordTitle.where('title LIKE ? OR title LIKE ? OR title LIKE ?', "%#{q}%", "%#{qj}%", "%#{q.downcase.katakana}%").order("char_length(title), seq").pluck(:seq).uniq
    words = Word.where(seq: seqs).with_progresses(current_user)
    @words = words.sort{|a,b| seqs.index(a.seq) <=> seqs.index(b.seq)}
  end

  slim :search
end

get :notes do
  protect!
  @title = "📘"

  @notes = current_user.notes.order(created_at: :desc)
  slim :notes
end

post :notes do
  protect!

  note = Note.create(content: params[:content], user: current_user)
  redirect path_to(:notes)
end

delete :note do
  protect!

  note = Note.find_by(id: params[:id], user_id: current_user.id)
  note.destroy

  flash[:notice] = "Note with id = #{params[:id]} was successfully deleted"
  redirect path_to(:notes)
end

get :login do
  if current_user.present?
    flash[:notice] = "Already logged in"
    redirect path_to(:index)
  else
    slim :login
  end
end

post :login do
  begin
    throw StandardError.new('Blank login or password') if params['username'].blank? || params['password'].blank?

    user = User.find_by(login: params['username'])
    throw StandardError.new('User not found') unless user.present?
    throw StandardError.new('Incorrect password') unless user.check_password(params['password'])

    flash[:notice] = "Successfully logged in as #{user.login}!"
    session['user_id'] = user.id
    redirect path_to(:index)
  rescue
    flash[:error] = "Incorrect username or password :("
    redirect path_to(:login)
  end
end

delete :logout do
  session.delete('user_id')
  flash[:notice] = "Successfully logged out"
  redirect path_to(:index)
end

post :settings do
  protect!

  if params['black_theme'] != nil
    current_user.settings['theme'] = (params['black_theme'] == 'true' ? 'black' : 'white')
  end
  current_user.save

  'ok'
end

get :word do
  protect!

  @word_seq = params[:id]

  slim :word
end

post :word_flag do
  protect!

  progress = Progress.find_or_initialize_by(
        seq: params[:seq],
        title: params[:kreb],
        user: current_user,
        kind: :w)
  progress.flagged = true
  progress.save

  return progress.to_json
end

post :word_learn do
  protect!

  progress = Progress.find_or_initialize_by(
        seq: params[:seq],
        title: params[:kreb],
        user: current_user,
        kind: :w)
  throw StandardError.new("Already learned") if progress.learned_at.present?

  unless progress.unlocked
    progress.unlocked = true
    progress.unlocked_at = DateTime.now
  end

  progress.learned_at = DateTime.now
  progress.deck = 0
  progress.save

  Action.create(user: current_user, progress: progress, action_type: :learned)

  stats = Statistic.find_or_initialize_by(user: current_user, date: Date.today)
  stats.learned['w'] += 1
  stats.save

  return progress.to_json
end

post :word_burn do
  protect!

  progress = Progress.find_by(id: params[:progress_id], user: current_user)
  progress.update_attribute(:burned_at, DateTime.now)

  Action.create(user: current_user, progress: progress, action_type: :burn)

  return progress.to_json
end

get :list_nf do
  protect!

  lvl = params[:nf].to_i
  @pagination = {current: "NF&nbsp;##{lvl}"}
  @pagination[:prev] = {href: path_to(:list_nf).with(lvl - 1), title: "NF&nbsp;##{lvl - 1}"} if lvl > 1
  @pagination[:next] = {href: path_to(:list_nf).with(lvl + 1), title: "NF&nbsp;##{lvl + 1}"} if lvl < 48

  @elements = Word.where(nf: params[:nf]).order(:seq).with_progresses(current_user)

  slim :list
end

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

post :sentences do
  protect!

  s = Sentence.new({
    japanese: params['japanese'],
    english: params['english'],
#    russian: params[''],
    structure: params['structure'].map{|k,v| v}
  })
  s.save

  s.words = Word.where(seq: s.structure.map{|i| i['seq']}.compact.uniq)

  return 'OK'
end

delete :sentence do
  protect!

  s = Sentence.find(params[:id])
  s.destroy

  return 'ok'
end

get :autocomplete_word do
  protect!

  ww = Word.where(seq: WordTitle.where(title: params['term']).pluck(:seq)).map{|i|
        {
            id: i.seq,
            value: "#{i.krebs[0]}: #{i.en[0]['gloss'][0]}",
            title: i.krebs[0],
            href: path_to(:word).with(i.seq)
        }
  }
  return ww.to_json
end

post :word_connect do
  protect!

  long = Word.find_by(seq: params[:long])
  short = Word.find_by(seq: params[:short])
  long.short_words << short

  return 'ok'
end

delete :word_connect do
  protect!

  long = Word.find_by(seq: params[:long])
  short = Word.find_by(seq: params[:short])
  long.short_words.delete(short)

  return 'ok'
end

get :study2 do
  protect!

  @sentence = Sentence.where.not(structure: nil).order('RANDOM()').first
  slim :study2
end

post :word_set_comment do
  protect!

  wd = WordDetail.find_or_create_by(user: current_user, seq: params[:id])
  wd.update_attribute(:comment, params[:comment].strip.present? ? params[:comment] : nil)

  return 'ok'
end

get :wk_word do
  protect!
  @element = WkWord.find(params[:id])
  slim :wk_element
end

get :wk_kanji do
  protect!
  @element = WkKanji.find(params[:id])
  slim :wk_element
end

get :wk_radical do
  protect!
  @element = WkRadical.find(params[:id])
  slim :wk_element
end

get :kanji do
  protect!
  @kanji = Kanji.find(params[:id])
  slim :kanji
end

get :list_jlpt_words do
  @view_user = current_user || User.first

  lvl = params[:level].to_i
  @pagination = {current: "JLPT&nbsp;N#{lvl}"}
  @pagination[:prev] = {href: path_to(:list_jlpt_words).with(lvl + 1), title: "JLPT&nbsp;N#{lvl + 1}"} if lvl < 5
  @pagination[:next] = {href: path_to(:list_jlpt_words).with(lvl - 1), title: "JLPT&nbsp;N#{lvl - 1}"} if lvl > 1

  @elements = Word.where(jlptn: params[:level]).order(:id).with_progresses(@view_user)
  slim :list
end

get :list_jlpt_kanji do
  @view_user = current_user || User.first

  lvl = params[:level].to_i
  @pagination = {current: "JLPT&nbsp;N#{lvl}"}
  @pagination[:prev] = {href: path_to(:list_jlpt_kanji).with(lvl + 1), title: "JLPT&nbsp;N#{lvl + 1}"} if lvl < 5
  @pagination[:next] = {href: path_to(:list_jlpt_kanji).with(lvl - 1), title: "JLPT&nbsp;N#{lvl - 1}"} if lvl > 1

  @elements = Kanji.where(jlptn: params[:level]).order(:id).with_progresses(@view_user)
  slim :list
end
