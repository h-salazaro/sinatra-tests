require './adserver'
require 'sass/plugin/rack'
require './lib/authorization'

Sass::Plugin.options[:style] = :compressed
use Sass::Plugin::Rack

run Sinatra::Application
