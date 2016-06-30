require 'sinatra/base'

class Root < Sinatra::Base

  get '/' do
    "I'm the root of the application"
  end

  get '/hello' do
    "I'm the Hello route in the ROOT app. Don't forget the last '/'"
  end

end
