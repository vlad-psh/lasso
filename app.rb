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

paths index: '/',
    card: '/card/:id',
    radicals: '/radicals',
    kanjis: '/kanjis',
    words: '/words',
    note: '/note/:id', # post
    learn: '/learn/:id', # post
    random_unlocked: '/random/:class', # get(redirection)
    study: '/study/:class/:group' # get, post

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
    "User-Agent" => "Mozilla/5.0 (X11; Linux x86_64; rv:55.0) Gecko/20100101 Firefox/55.0",
    "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language" => "en-US,en;q=0.5",
    "Referer" => "http://www.weblio.jp/"
  }
end

helpers WakameHelpers

get :index do
  @current_counters = Card.to_learn.group(:element_type).count

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

get :radicals do
  @elements = Card.radicals.order(level: :asc, id: :asc)
  @title = "部首"
  slim :elements_list
end

get :kanjis do
  @elements = Card.kanjis.order(level: :asc, id: :asc)
  @title = "漢字"
  slim :elements_list
end

get :words do
  @elements = Card.words.order(level: :asc, id: :asc)
  @title = "言葉"
  slim :elements_list
end

post :note do
  e = Card.find(params[:id])
  e.detailsb["mynotes"] = params[:content]
  e.save

  return bb_textile(e.detailsb["mynotes"])
end

post :learn do
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
  e = Card.find(params[:element_id])
  halt(400, 'Element not found') unless e

  e.answer!(params[:answer])

  redirect path_to(:study).with(safe_type(params[:class]), safe_group(params[:group]))
end

