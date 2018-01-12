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
    current: '/current', # get(redirection)
    degree: '/degree/:degree/:class',
    level: '/level/:level',
    card: '/card/:id',
    note: '/note/:id', # post
    learn: '/learn/:id', # post
    study: '/study/:class/:group', # get, post
    search: '/search', # post
    toggle_compact: '/toggle_compact', # post
    notes: '/notes',
    login: '/login', # GET: login form; POST: log in
    logout: '/logout' # DELETE: logout

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
  @counters = {}
  [:just_unlocked, :just_learned, :failed, :expired, :any_learned].each do |g|
    @counters[g] = Card.public_send(g).group(:element_type).count
  end

  slim :index
end

get :card do
  hide!

  @element = Card.find(params[:id])
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
  redirect path_to(:level).with(Card.current_level)
end

get :level do
  @radicals = Card.radicals.where(level: params[:level]).order(id: :asc)
  @kanjis   = Card.kanjis.where(level: params[:level]).order(id: :asc)
  @words    = Card.words.where(level: params[:level]).order(id: :asc)

  @title = "L.#{params[:level]}"
  @separate_list = true

  slim :level
end

get :degree do
  stype = safe_type(params[:class])
  d = params[:degree].to_i
  @elements = Card.public_send(stype).where(level: (d*10+1)..(d*10+10)).order(level: :asc, id: :asc)
  @title = DEGREES[d]
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

get :study do
  hide!

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
  hide!

  q = params['query']
  @elements = Card.where("title ILIKE ? OR detailsb->>'en' ILIKE ?", "%#{q}%", "%#{q}%").order(level: :asc)
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

delete :note do
  protect!

  note = Note.find(params[:id])
  note.destroy
  flash[:notice] = "Note with id = #{params[:id]} was successfully deleted"
  redirect path_to(:notes)
end

get :login do
  if admin? || guest?
    flash[:notice] = "Already logged in"
    redirect path_to(:index)
  else
    slim :login
  end
end

post :login do
  if params['username'].blank? || params['password'].blank?
    flash[:error] = "Incorrect username or password :("
    redirect path_to(:login)
  elsif $config['admins'] && $config['admins'][params['username']] == params['password']
    flash[:notice] = "Successfully logged in as admin!"
    session['role'] = 'admin'
    redirect path_to(:index)
  elsif $config['guests'] && $config['guests'][params['username']] == params['password']
    flash[:notice] = "Successfully logged in as spectator!"
    session['role'] = 'guest'
    redirect path_to(:index)
  else
    flash[:error] = "Incorrect username or password :("
    redirect path_to(:login)
  end
end

delete :logout do
  session.delete('role')
  flash[:notice] = "Successfully logged out"
  redirect path_to(:index)
end
