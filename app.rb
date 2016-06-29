#!/usr/bin/env ruby
require 'sinatra'

# set utf-8 encoding
before do
  headers "Content-Type" => "text/html; charset=utf-8"
end

get '/' do
  "Hello there, cowboy"
end

get'/greet/:name' do
  "Hello, #{params[:name]}"
end

get '/this/*/is/*' do
  params[:splat].join(" ")
end

get '/time' do
  "Time is #{Time.now.strftime('%I:%M:%S %p')}"
end

get '/template' do
  @title = "Fly me to the moon"
  haml :form
end

post '/template' do
  @name = "#{params[:post][:first_name]} #{params[:post][:last_name]}"
  @title = "#{params[:post][:first_name]}"
  haml :hello
end
