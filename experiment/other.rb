require 'sinatra/base'

class Other < Sinatra::Base

  get '/' do
    "I'm in the OTHER app."
  end

end

