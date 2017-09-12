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
    radical: '/radical/:name',
    kanjis: '/kanjis',
    kanji: '/kanji/:name',
    words: '/words',
    word: '/word/:id'

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
  # cl is a CurrentLevel information
  cl = {r: {}, k: {}, w: {}}
  cl[:r][:level], cl[:r][:count] = Radical.where(unlocked: false).order(level: :asc).group(:level).count.first
  cl[:k][:level], cl[:k][:count] = Kanji.where(unlocked: false).order(level: :asc).group(:level).count.first
  cl[:w][:level], cl[:w][:count] = Word.where(unlocked: false).order(level: :asc).group(:level).count.first
  @current_level = cl

  slim :index
end

get :radicals do
  @elements = Radical.all.order(level: :asc)
  slim :elements_list
end

get :radical do
  @radical = Radical.find_by(en: params[:name])
  slim :element
end

get :kanjis do
  @elements = Kanji.all.order(level: :asc)
  slim :elements_list
end

get :kanji do
  @kanji = Kanji.find_by(title: params[:name])
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
