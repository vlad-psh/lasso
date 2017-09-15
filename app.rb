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
    radicals: '/radicals',
    radical: '/radical/:id',
    kanjis: '/kanjis',
    kanji: '/kanji/:id',
    words: '/words',
    word: '/word/:id',
    learn: '/learn/:class/:id',
    study: '/study/:class/:group'

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
  [Radical, Kanji, Word].each do |k|
    @counters[k.model_name.singular.to_sym] = {
        just_unlocked: k.just_unlocked.count,
        just_learned: k.just_learned.count,
        failed: k.failed.count,
        expired: k.expired.count}
  end

  slim :index
end

get :radicals do
  @elements = Radical.all.order(level: :asc)
  slim :elements_list
end

get :radical do
  @radical = Radical.find(params[:id])
  slim :element
end

get :kanjis do
  @elements = Kanji.all.order(level: :asc)
  slim :elements_list
end

get :kanji do
  @kanji = Kanji.find(params[:id])
  slim :element
end

get :words do
  @elements = Word.all.order(level: :asc)
  slim :elements_list
end

get :word do
  @word = Word.find(params[:id])
  slim :element
end

post :learn do
  c = get_element_class(params[:class])
  e = c.find(params[:id])
  e.learn!
end

get :study do
  halt(400, "Unknown group \"#{params[:group]}\"") unless ['failed', 'expired', 'just_learned'].include?(params[:group])
  c = get_element_class(params[:class])
  @element = c.send(params[:group]).order('RANDOM()').first
  if @element
    slim :study
  else
    flash[:notice] = "No more items in \"#{params[:group]}\" group"
    redirect path_to(:index)
  end
end

post :study do
  c = get_element_class(params[:class])
  e = c.find(params[:element_id])
  halt(400, 'Element not found') unless e

  halt(400, 'Unknown answer') unless [:yes, :no].include?(params[:answer].to_sym)
  e.answer!(params[:answer])

  redirect path_to(:study).with(params[:class], params[:group])
end
