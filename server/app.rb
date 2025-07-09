require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'sinatra/content_for'
require 'sinatra/json'
require 'sinatra-snap'
require 'rack/contrib'

require 'yaml'
require 'mojinizer'
require 'open-uri'
require 'mini_magick'

Dir.glob('./models/*.rb').each {|model| require_relative model}
Dir.glob('./controllers/*.rb').each {|model| require_relative model}
require_relative './helpers.rb'
require_relative './collector.rb'

also_reload './models/*.rb'
also_reload './controllers/*.rb'
also_reload './helpers.rb'
also_reload './collector.rb'

helpers WakameHelpers

configure do
  $config = YAML.load(File.open('config/application.yml'))

  use Rack::JSONBodyParser
  use Rack::Session::Cookie,
        key: 'wakame',
#        domain: 'localhost:3000',
#        path: '/',
        expire_after: 2592000, # 30 days
        secret: $config['secret'],
        same_site: :strict,
        httponly: true # cookies shouldn't be sent from JS

  SRS_RANGES = [0, 3, 7, 14, 30, 60, 120, 240]
end

