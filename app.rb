require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'sinatra/content_for'
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

paths cards: '/cards',
    notes: '/notes',
    note: '/note/:id',
# Element's pages
    word: '/word/:id',
    kanji: '/kanji/:id',
    wk_radical: '/wk_radical/:id',
# Other API
    sentences: '/sentences', # POST
    sentence: '/sentence/:id' # DELETE

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

  DEGREES = ['快 Pleasant', '苦 Painful', '死 Death', '地獄 Hell', '天堂 Paradise', '現実 REALITY']
  INFODIC = {
    :r => {singular: :radical, plural: :radicals, japanese: '部首'},
    :k => {singular: :kanji, plural: :kanji, japanese: '漢字'},
    :w => {singular: :word, plural: :words, japanese: '言葉'}
  }
  SRS_RANGES = [0, 3, 7, 14, 30, 60, 120, 240]
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

get :word do
  protect!

  slim :word
end

get :sentences do
  protect!

  @sentences = Sentence.where(user: current_user).order(created_at: :desc).limit(50)

  slim :sentences
end

post :sentences do
  protect!

  drill = Drill.find_by(user: current_user, id: params['drill_id'])

  s = Sentence.new({
    japanese: params['japanese'],
    english: params['english'],
#    russian: params[''],
    structure: params['structure'].map{|k,v| v},
    drill: drill,
    user: current_user
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

get :wk_radical do
  protect!
  @radical = WkRadical.find(params[:id])
  slim :wk_radical
end

get :kanji do
  protect!
  @kanji = Kanji.find(params[:id])
  if @kanji.wk_kanji.present?
    @words = Word.joins(:wk_words).merge(@kanji.wk_kanji.wk_words).as_for(current_user)
  end
  slim :kanji
end


