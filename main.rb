require 'rubygems'
require 'sinatra'

set :sessions, true

get '/form' do
    erb :form
end


get '/game' do
  # deck
  suits = ['H', 'D', 'C', 'S']
  values = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"] 
  session[:deck] = suits.product(values).shuffle!
  # deal cards
  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop

  erb :game
end

post '/game' do
  session[:name] = params[:name]
  redirect '/game'
end

get '/' do
  if session[:name]
    redirect '/game'
  else
    redirect '/form'
  end
end

get '/nested_template' do
  erb :"/users/profile"
end
