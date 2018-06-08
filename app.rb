require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'sinatra-snap'
require 'slim'

require 'rack-flash'
require 'yaml'
require 'redcloth'
require 'httparty'
require 'nokogiri'
require 'mojinizer'
require 'open-uri'

require_relative './models.rb'
require_relative './helpers.rb'

also_reload './models.rb'
also_reload './helpers.rb'

helpers WakameHelpers

paths index: '/',
    list: '/list/:class',
    current: '/current', # get(redirection)
    term: '/term/:term/:class',
    level: '/level/:level',
    cards: '/cards',
    card: '/card/:id',
    cardinfo: '/cardinfo/:id', # post
    learn: '/learn/:id', # post
    study: '/study/:class/:group', # get, post
    search: '/search', # post
    toggle_compact: '/toggle_compact', # post
    notes: '/notes',
    note: '/note/:id',
    login: '/login', # GET: login form; POST: log in
    logout: '/logout', # DELETE: logout
    settings: '/settings',
    stats: '/stats'

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
end

get :index do
  @view_user = current_user || User.first
  @counters = {}
  [:just_unlocked, :just_learned, :failed, :expired, :any_learned].each do |g|
    @counters[g] = Card.joins(:user_cards).merge( UserCard.public_send(g).where(user: @view_user) ).group(:element_type).count
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

  uc = UserCard.find_or_initialize_by(card: c, user: current_user)
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

  redirect path_to(:search).with(query: params['query'])
end

get :card do
  protect!

  @element = Card.find(params[:id])
  @element.uinfo = UserCard.find_by(card_id: params[:id], user_id: current_user.id)

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

  cards = Card.where(level: params[:level]).order(id: :asc).with_uinfo(@view_user)

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
  @elements = Card.public_send(stype).where(level: (d*10+1)..(d*10+10)).order(level: :asc, id: :asc).with_uinfo(@view_user)
  @title = DEGREES[d]
  @separate_list = true
  slim :elements_list
end

post :cardinfo do
  protect!

  sprop = params[:property_name].to_sym
  allowed_props = {my_meaning: :m, my_reading: :r, my_en: :t}
  throw StandardError.new("Unknown property: #{sprop}") unless allowed_props.keys.include?(sprop)

  e = UserCard.find_or_initialize_by(card_id: params[:id], user_id: current_user.id)
  e.details ||= {}
  e.details[allowed_props[sprop]] = params[:content]
  e.save

  return bb_textile(e.details[allowed_props[sprop].to_s])
end

post :learn do
  protect!

  e = Card.find(params[:id])
  e.learn_by!(current_user)

  redirect path_to(:card).with(params[:id])
end

get :study do
  protect!

  ucards = UserCard.public_send(safe_group(params[:group])).where(user: current_user)
  elements = Card.public_send(safe_type(params[:class])).joins(:user_cards).merge(ucards)
  @element = elements.order('RANDOM()').first

  if @element.present?
    @element.uinfo = UserCard.find_by(card: @element, user: current_user)
    @count = elements.count
    slim :study
  else
    flash[:notice] = "No more #{params[:class]} in \"#{params[:group]}\" group"
    redirect path_to(:index)
  end
end

post :study do
  protect!

  e = Card.find(params[:element_id])
  halt(400, 'Element not found') unless e

  e.answer_by!(params[:answer], current_user)

  redirect path_to(:study).with(safe_type(params[:class]), safe_group(params[:group]))
end

get :search do
  protect!

  @elements = []
  if q = params['query']
    qj = q.downcase.hiragana
    if q.length > 1
      @elements = Card.where("title ILIKE ? OR detailsb->>'en' ILIKE ? OR detailsb->>'readings' LIKE ?", "%#{q}%", "%#{q}%", "%#{qj}%").order(level: :asc)
      @russian_words = RussianWord.where("title ILIKE ?", "#{q}%").order(id: :asc)
    else
      @elements = qj.japanese? ? Card.where("title ILIKE ? OR detailsb->>'readings' LIKE ?", "%#{qj}%", "%#{qj}%").order(level: :asc) : Card.none
      @russian_words = RussianWord.none
    end
  end
  slim :search
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

get :stats do
  protect!

  slim :stats
end
