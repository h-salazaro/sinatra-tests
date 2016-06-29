#!/usr/bin/env ruby

require 'sinatra'

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
  @title = "#{params[:post][:first_name]}"
  haml "Hello, #{params[:post][:first_name]} #{params[:post][:last_name]}"
end

__END__

@@layout
%html
  %head
    %title= @title
  =yield

@@fly
.title
  %h1= @title

@@form
%form{action: "/template", method: "POST"}
  %input{type: "text", name: "post[first_name]", size: 20}
  %input{type: "text", name: "post[last_name]", size: 20}
  %input{type: "submit", value: "Say hi"}
