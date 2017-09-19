require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'sinatra-snap'
require 'slim'

require 'rack-flash'
require 'yaml'
require 'redcloth'

require_relative './models.rb'
require_relative './helpers.rb'

also_reload './models.rb'
also_reload './helpers.rb'

paths index: '/',
    card: '/card/:id',
    radicals: '/radicals',
    kanjis: '/kanjis',
    words: '/words',
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
end

helpers WakameHelpers

get :index do
  @counters = {}
  [:radicals, :kanjis, :words].each do |k|
    @counters[k] = {
        just_unlocked: Card.public_send(k).just_unlocked.count,
        just_learned: Card.public_send(k).just_learned.count,
        failed: Card.public_send(k).failed.count,
        expired: Card.public_send(k).expired.count}
  end

  slim :index
end

get :card do
  @element = Card.find(params[:id])
  slim :element
end

get :radicals do
  @elements = Card.radicals.order(level: :asc)
  @title = "部首"
  slim :elements_list
end

get :kanjis do
  @elements = Card.kanjis.order(level: :asc)
  @title = "漢字"
  slim :elements_list
end

get :words do
  @elements = Card.words.order(level: :asc)
  @title = "言葉"
  slim :elements_list
end

post :learn do
  e = Card.find(params[:id])
  e.learn!

  redirect path_to(:card).with(params[:id])
end

get :random_unlocked do
  e = Card.public_send(safe_type(params[:class])
        ).just_unlocked.order(level: :asc).order('RANDOM()').first
  if e
    redirect path_to(:card).with(e.id)
  else
    flash[:notice] = "No more unlocked #{params[:class]}"
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

