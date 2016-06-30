require './root'
require './hello'
require 'other'

map '/' do
  run Root
end

map '/hello' do
  run Hello
end

map '/other' do
  run Other
end
