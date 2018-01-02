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

require_relative './models.rb'
require_relative './helpers.rb'

also_reload './models.rb'
also_reload './helpers.rb'

helpers WakameHelpers

paths index: '/',
    list: '/list/:class',
    current: '/current/:class', # get(redirection)
    difficulty: '/difficulty/:difficulty/:class',
    level: '/level/:level/:class',
    card: '/card/:id',
    note: '/note/:id', # post
    learn: '/learn/:id', # post
    random_unlocked: '/random/:class', # get(redirection)
    study: '/study/:class/:group', # get, post
    search: '/search', # post
    toggle_compact: '/toggle_compact', # post
    notes: '/notes',
    login: '/login' # GET: login form; POST: log in; DELETE: log out

configure do
  puts '---> init <---'

  $config = YAML.load(File.open('config/application.yml'))

  use Rack::Session::Cookie,
#        key: 'fcs.app',
#        domain: '172.16.0.11',
#        path: '/',
#        expire_after: 2592000,
        secret: $config['secret']

  use Rack::Flash

  $weblio_headers = {
    "User-Agent" => "Mozilla/5.0 (X11; Linux x86_64; rv:57.0) Gecko/20100101 Firefox/57.0",
    "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language" => "en-US,en;q=0.5",
    "Referer" => "https://www.weblio.jp/"
  }
end

get :index do
  @counters = {}
  [:just_unlocked, :just_learned, :failed, :expired].each do |g|
    @counters[g] = Card.public_send(g).group(:element_type).count
  end

  slim :index
end

get :card do
  @element = Card.find(params[:id])
  if @element.element_type == 'w' && @element.detailsb['pitch'] == nil
    @element.detailsb['pitch'] = weblio_pitch(@element.title)
    @element.save
  end
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
  redirect path_to(:level).with(Card.current_level, params[:class])
end

get :level do
  stype = safe_type(params[:class])
  @elements = Card.public_send(stype).where(level: params[:level]).order(id: :asc)
  @title = case stype
    when :radicals then "部首##{params[:level]}"
    when :kanjis then "漢字##{params[:level]}"
    when :words then "言葉##{params[:level]}"
  end
  @separate_list = true
  slim :elements_list
end

get :difficulty do
  stype = safe_type(params[:class])
  d = params[:difficulty].to_i
  @elements = Card.public_send(stype).where(level: (d*10+1)..(d*10+10)).order(level: :asc, id: :asc)
  @separate_list = true
  slim :elements_list
end

post :note do
  protect!

  sprop = params[:property_name].to_sym
  allowed_props = [:my_meaning, :my_reading, :my_en]
  throw StandardError.new("Unknown property: #{sprop}") unless allowed_props.include?(sprop)

  e = Card.find(params[:id])
  e.detailsb[sprop.to_s] = params[:content]
  e.save

  return bb_textile(e.detailsb[sprop.to_s])
end

post :learn do
  protect!

  e = Card.find(params[:id])
  e.learn!

  redirect path_to(:card).with(params[:id])
end

get :random_unlocked do
  etype = safe_type(params[:class])
  e = Card.public_send(etype).just_unlocked.order(level: :asc).order('RANDOM()').first

  if e
    redirect path_to(:card).with(e.id)
  else
    flash[:notice] = "No more unlocked #{params[:class]}"

    if etype == :radicals
      # unlock next level
      lowest_locked = Card.radicals.locked.order(level: :asc).first
      Card.public_send(etype).locked.where(level: lowest_locked.level).each do |c|
        c.unlock!
      end if lowest_locked
    end

    redirect path_to(:index)
  end
end

get :study do
  protect!

  @element = Card.public_send(safe_type(params[:class])
        ).public_send(safe_group(params[:group])
        ).order('RANDOM()').first

  if @element
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

  e.answer!(params[:answer])

  redirect path_to(:study).with(safe_type(params[:class]), safe_group(params[:group]))
end

post :search do
  q = params['query']
  @elements = Card.where('title LIKE ?', "%#{q}%")
  @separate_list = true
  slim :elements_list
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

  @notes = Note.all.order(created_at: :desc)
  slim :notes
end

post :notes do
  protect!

  note = Note.create(content: params[:content])
  redirect path_to(:notes)
end

get :login do
  if authorized?
    flash[:notice] = "Already logged in"
    redirect path_to(:index)
  else
    slim :login
  end
end

post :login do
  if $config['username'] == params['username'] && $config['password'] == params['password']
    flash[:notice] = "Successfully logged in!"
    session['username'] = $config['username']
    redirect path_to(:index)
  else
    flash[:error] = "Incorrect username or password :("
    redirect path_to(:login)
  end
end
