require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'sinatra-snap'
require 'slim'

require 'rack-flash'
require 'yaml'

require_relative './models.rb'

also_reload './models.rb'

paths index: '/'

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

get :index do
  # cl is a CurrentLevel information
  cl = {r: {}, k: {}, w: {}}
  cl[:r][:level], cl[:r][:count] = Radical.where(unlocked: false).order(level: :asc).group(:level).count.first
  cl[:k][:level], cl[:k][:count] = Kanji.where(unlocked: false).order(level: :asc).group(:level).count.first
  cl[:w][:level], cl[:w][:count] = Word.where(unlocked: false).order(level: :asc).group(:level).count.first
  @current_level = cl

  slim :index
end

