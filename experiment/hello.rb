require 'sinatra/base'

class Hello < Sinatra::Base

  get '/' do
    "Hello, there. I'm in the Hello App"
  end

  get '/greet/:name' do
    "Hello, #{params[:name]}"
  end


end
