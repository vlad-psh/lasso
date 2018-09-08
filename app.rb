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
    list: '/list/:class',
    current: '/current', # get(redirection)
    term: '/term/:term/:class',
    level: '/level/:level',
    cards: '/cards',
    card: '/card/:id',
    learn: '/learn/:id', # post
    study: '/study/:class/:group', # get, post
    search: '/search', # post
    toggle_compact: '/toggle_compact', # post
    notes: '/notes',
    note: '/note/:id',
    login: '/login', # GET: login form; POST: log in
    logout: '/logout', # DELETE: logout
    settings: '/settings',
    words_nf: '/words/:nf',
    word: '/word/:id',
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
    link_word_to_card: '/linkw2c',
    disable_card: '/disable_card',
    study2: '/study2'

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
    :k => {singular: :kanji, plural: :kanjis, japanese: '漢字'},
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

  k_jlpt = Card.kanjis.joins(:progresses).merge( Progress.where(user: @view_user).where.not(learned_at: nil) ).group("detailsb->>'jlpt'").count
  # {"5"=>103, "4"=>181, "3"=>367, "2"=>400, "1"=>1207} # non-cumulative
  # {"5"=>103, "4"=>284, "3"=>651, "2"=>1051, "1"=>2258} # cumulative
  k_total = {"5"=>103, "4"=>284, "3"=>651, "2"=>1051, "1"=>2258}
  cumulative = 0
  %w(5 4 3 2 1).each do |lvl|
    cumulative += k_jlpt[lvl] || 0
    @counters["n#{lvl}".to_sym] = {'k' => (100.0*cumulative/k_total[lvl]).round}
  end

  w_jlpt = Card.words.joins(:progresses).merge( Progress.where(user: @view_user).where.not(learned_at: nil) ).group("detailsb->>'jlpt'").count
  # {"5"=>438, "4"=>416, "3"=>964, "2"=>531, "1"=>681} # word cards in db + 3284 of unknown level
  # {"5"=>438, "4"=>854, "3"=>1818, "2"=>2349, "1"=>3030} # same as above but cumulative
  # {"5"=>602, "4"=>595, "3"=>2165, "2"=>3249, "1"=>2708} # real life total counts
  # {"5"=>602, "4"=>1197, "3"=>3362, "2"=>6611, "1"=>9319} # same as above but cumulative
  w_total = {"5"=>438, "4"=>854, "3"=>1818, "2"=>2349, "1"=>3030}
  cumulative = 0
  %w(5 4 3 2 1).each do |lvl|
    cumulative += w_jlpt[lvl] || 0
    @counters["n#{lvl}".to_sym] ||= {}
    @counters["n#{lvl}".to_sym]['w'] = (100.0*cumulative/w_total[lvl]).round
  end

  slim :index
end

post :cards do
  protect!

  c = Card.create(
        element_type: :w,
        title: params['title'],
        level: (params['type'] == 'burned' ? 100 : 99),
        detailsb: {
            en: [params['en']],
            readings: [params['reading']],
            user_id: current_user.id # author
          }
        )

  uc = Progress.find_or_initialize_by(card: c, user: current_user)
  uc.unlocked = true
  uc.deck = 0
  uc.save

  if params['type'] == 'burned'
    uc.update(learned: true)
    c.move_to_deck_by!(100, current_user)
  elsif params['type'] == 'learned'
    c.learn_by!(current_user)
#  elsif params['type'] == 'unlocked'
#    c.level = 99
  end

  redirect "#{path_to(:search)}?query=#{params['search']}"
end

get :card do
  protect!

  @element = Card.find(params[:id])
  @element.progress = Progress.find_by(card_id: params[:id], user_id: current_user.id)

  slim :element
end

get :list do
  stype = safe_type(params[:class])
  @elements = Card.public_send(stype).order(level: :asc, id: :asc)
  @title = case stype
    when :radicals then "部首"
    when :kanjis then "漢字"
    when :words then "言葉"
  end
  @separate_list = true
  slim :elements_list
end

get :current do
  redirect path_to(:level).with(current_user.present? ? current_user.current_level : 1)
end

get :level do
  @view_user = current_user || User.first
  @radicals, @kanjis, @words = [], [], []

  cards = Card.where(level: params[:level]).order(id: :asc).with_progress(@view_user)

  cards.each do |c|
    @radicals << c if c.radical?
    @kanjis   << c if c.kanji?
    @words    << c if c.word?
  end

  @title = "L.#{params[:level]}"
  @separate_list = true

  slim :level
end

get :term do
  @view_user = current_user || User.first
  stype = safe_type(params[:class])
  d = params[:term].to_i
  @elements = Card.public_send(stype).where(level: (d*10+1)..(d*10+10)).order(level: :asc, id: :asc).with_progress(@view_user)
  @title = DEGREES[d]
  @separate_list = true
  slim :elements_list
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

  @elements = Card.none
  @russian_words = RussianWord.none
  @jmelements = []
  q = params['query'].strip
  @title = "🔎 #{q}"

  if q.present?
    qj = q.downcase.hiragana

    if q.length > 1
      @elements = Card.where("title ILIKE ? OR detailsb->>'en' ILIKE ? OR detailsb->>'readings' LIKE ?", "%#{q}%", "%#{q}%", "%#{qj}%").order(level: :asc)
      @russian_words = RussianWord.where("title ILIKE ?", "#{q}%").order(id: :asc)
    else
      @elements = qj.japanese? ? Card.where("title ILIKE ? OR detailsb->>'readings' LIKE ?", "%#{qj}%", "%#{qj}%").order(level: :asc) : Card.none
    end

    seqs = WordTitle.where('title LIKE ? OR title LIKE ? OR title LIKE ?', "%#{q}%", "%#{qj}%", "%#{q.downcase.katakana}%").order("char_length(title), seq").pluck(:seq).uniq
    words = Word.where(seq: seqs).with_progresses(current_user)
    @words = words.sort{|a,b| seqs.index(a.seq) <=> seqs.index(b.seq)}
  end

#  if @elements.count == 1
#    redirect path_to(:card).with(@elements.first.id)
#  else
    slim :search
#  end
end

post :toggle_compact do
  if params["compact"]
    request.session["compact"] = true
    return 200, '{"compact": true}'
  else
    request.session["compact"] = false
    return 200, '{"compact": false}'
  end
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

  progress = Progress.find_or_create_by(seq: params[:seq], title: params[:kreb], user: current_user)
  progress.update_attribute(:flagged, true)

  return progress.to_json
end

post :word_learn do
  protect!

  progress = Progress.find_or_create_by(seq: params[:seq], title: params[:kreb], user: current_user)
  throw StandardError.new("Already learned") if progress.learned

  unless progress.unlocked
    progress.unlocked = true
    progress.unlocked_at = DateTime.now
  end

  progress.learned = true
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

get :words_nf do
  protect!

  @view_user = current_user || User.first
  @words = Word.where(nf: params[:nf]).order(:seq).with_progresses(@view_user)

  slim :words
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

post :link_word_to_card do
  protect!

  card = Card.find(params[:card_id])
  word = Word.find_by(seq: params[:word_id])
  card.update_attribute(:seq, word.seq)
  word.update_attribute(:card_id, card.id)

  card.progresses.each do |p|
    p.update_attribute(:seq, word.seq)
  end

  redirect path_to(:card).with(card.id)
end

post :disable_card do
  protect!

  c = Card.find(params['card_id'])
  c.update_attribute(:is_disabled, true)
  c.progresses.each do |p|
    p.update_attribute(:burned_at, DateTime.now)
  end

  redirect path_to(:card).with(c.id)
end

post :word_set_comment do
  protect!

  wd = WordDetail.find_or_create_by(user: current_user, seq: params[:id])
  wd.update_attribute(:comment, params[:comment].strip.present? ? params[:comment] : nil)

  return 'ok'
end
