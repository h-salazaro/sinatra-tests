require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'dm-migrations'
require 'dm-timestamps'
require './lib/authorization'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/adserver.db")

class Ad

  include DataMapper::Resource

  property :id,           Serial
  property :title,        String
  property :content,      Text
  property :width,        Integer
  property :height,       Integer
  property :filename,     String
  property :url,          String
  property :is_active,    Boolean
  property :created_at,   DateTime
  property :updated_at,   DateTime
  property :size,         Integer
  property :content_type, String

  has n, :clicks

  def handle_upload( file )
    self.content_type = file[:type]
    self.size = File.size(file[:tempfile])
    path = File.join(Dir.pwd, '/public/ads', self.filename)
    File.open(path, "wb") do |f|
      f.write(file[:tempfile].read)
    end
  end

end

class Click

  include DataMapper::Resource

  property :id,           Serial
  property :ip_address,   String
  property :created_at,   DateTime

  belongs_to :ad

end

configure :development do
  DataMapper.auto_upgrade!
end


helpers do
  include Sinatra::Authorization
end

get '/' do
  @title = "Welcome to my humble server"
  haml :welcome
end

get '/ad' do
  id = repository(:default).adapter.query(
    'SELECT id FROM ads ORDER BY random() LIMIT 1'
  )
  @ad = Ad.get(id)
  erb :ad
end

get '/list' do
  require_admin
  @title = "List ads"
  @ads = Ad.all(order: [:created_at.desc])
  haml :list
end

get '/new' do
  require_admin
  @title = "Create a new ad"
  haml :new
end

post '/create' do
  require_admin
  @ad = Ad.new(params[:ad])
  @ad.handle_upload(params[:image])
  if @ad.save
    path = File.join(Dir.pwd, "/public/ads", @ad.filename)
    File.open(path, "wb") do |f|
      f.write(params[:image][:tempfile].read)
    end
    redirect "/show/#{@ad.id}"
  else
    redirect '/list'
  end
end

get '/delete/:id' do
  require_admin
  ad = Ad.get(params[:id])
  unless ad.nil?
    path = File.join(Dir.pwd, "public/ads", ad.filename)
    File.delete(path)
    ad.destroy
  end
  redirect '/list'
end

get '/show/:id' do 
  require_admin
  @ad = Ad.get(params[:id])
  if @ad 
    haml :show
  else redirect '/list'
  end
end

get '/click/:id' do
  ad = Ad.get(params[:id])
  ad.clicks.create(:ip_address => env["REMOTE_ADDR"])
  redirect(ad.url)
end
