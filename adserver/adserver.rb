require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'dm-migrations'

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

end

class Click

  include DataMapper::Resource

  property :id,           Serial
  property :ip_address,   String
  property :created_at,   DateTime

  belongs_to :ad

end

DataMapper.auto_upgrade!

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
  @title = "List ads"
  @ads = Ad.all(order: [:created_at.desc])
  haml :list
end

get '/new' do
  @title = "Create a new ad"
  haml :new
end

post '/create' do
  @ad = Ad.new(params[:ad])
  @ad.content_type = params[:image][:type]
  @ad.size = File.size(params[:image][:tempfile])
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
  ad = Ad.get(params[:id])
  unless ad.nil?
    path = File.join(Dir.pwd, "public/ads", ad.filename)
    File.delete(path)
    ad.destroy
  end
  redirect '/list'
end

get '/show/:id' do 
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
