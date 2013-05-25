require 'rubygems'
require 'sinatra'
require 'pry'
set :sessions, true

get '/' do
  session.delete :player_turn

  if session[:player_name]
    redirect '/game'
  else
    redirect '/form'
  end
end

get '/form' do
  erb :form
end

post '/form' do
  if params[:player_name].nil? || params[:player_name].empty?
      @error = "You must enter a name!"
      erb :form
  else
    session[:player_name] = params[:player_name]
    redirect '/game'
  end
end


get '/game' do
  # binding.pry
  if session[:player_name].nil? || session[:player_name].empty?
    redirect '/form'
  end

  if session[:player_turn] == "player"
    erb :game
  elsif session[:player_turn] == "dealer"
    # begin dealer turn
    "BEGIN DEALER TURN"
  else
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

    session[:player_turn] = "player"
    erb :game
  end
end

post '/game' do
  # actions for player using turn buttons
  if params[:player_action] == 'hit'
    session[:player_cards] << session[:deck].pop
  elsif params[:player_action] == 'stay'
    session[:player_turn] = "dealer"
  end

  redirect '/game'
end