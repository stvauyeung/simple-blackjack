require 'rubygems'
require 'sinatra'

set :sessions, true

get '/home' do
	"Blackjack, coming soon! Badum!!!"
end

get '/' do
  erb :index
end

get '/nested_template' do
  erb :"/users/profile"
end

get '/redirect' do
  redirect '/'
end