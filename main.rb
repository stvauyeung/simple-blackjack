require 'rubygems'
require 'sinatra'
require 'pry'
set :sessions, true

helpers do
  def calculate_total(cards)
    arr = cards.map{|element| element[1]}

    total = 0
    arr.each do |a|
      if a == 'A'
        total += 11
      else
        total += a.to_i == 0 ? 10 : a.to_i
      end
    end

    arr.select{|element| element == 'A'}.count.times do
      break if total <= 21
      total -= 10
    end

    total
  end

  def to_image(card)
    case card[0]
      when 'H' then @suit = 'hearts'
      when 'D' then @suit = 'diamonds'
      when 'C' then @suit = 'clubs'
      when 'S' then @suit = 'spades'
    end

    "<img src='images/cards/#{@suit}_#{card[1]}.jpg' alt='#{card[1]} of #{@suit}'>"
  end

  def blackjack_or_bust(cards)
    if calculate_total(cards) == 21
      session[:player_turn] = "dealer"
      redirect '/game'
      @error = "#{session[:player_name]} hit 21!"
    elsif calculate_total(cards) > 21
      session[:player_turn] = "dealer"
      redirect '/game'
      @error = "#{session[:player_name]} busted."
    end
  end
end

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
    blackjack_or_bust(session[:player_cards])
    erb :game
  elsif session[:player_turn] == "dealer"
    erb :dealer
  else
    # deck
    suits = ['H', 'D', 'C', 'S']
    values = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "jack", "queen", "king", "ace"] 
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