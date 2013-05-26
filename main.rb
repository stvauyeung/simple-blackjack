require 'rubygems'
require 'sinatra'

set :sessions, true

helpers do
  def calculate_total(cards)
    arr = cards.map{|element| element[1]}

    total = 0
    arr.each do |a|
      if a == 'ace'
        total += 11
      else
        total += a.to_i == 0 ? 10 : a.to_i
      end
    end

    arr.select{|element| element == 'ace'}.count.times do
      break if total <= 21
      total -= 10
    end

    total
  end

  def card_image(card)
    case card[0]
      when 'H' then suit = 'hearts'
      when 'D' then suit = 'diamonds'
      when 'C' then suit = 'clubs'
      when 'S' then suit = 'spades'
    end

    "<img src='/images/cards/#{suit}_#{card[1]}.jpg' alt='#{card[1]} of #{suit}' class='card_image'>"
  end
end

before do
  @player_buttons = true
end

get '/' do
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
      halt erb(:form)
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

  if calculate_total(session[:player_cards]) == 21
    @success = "You hit blackjack!"
    @player_buttons = false
  end

  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop
  if calculate_total(session[:player_cards]) > 21
    @error = "Sorry, you have busted."
    @player_buttons = false
  elsif calculate_total(session[:player_cards]) == 21
    @success = "You hit twenty-one!"
    @player_buttons = false
  end

  erb :game
end

post '/game/player/stay' do
  @success = "#{session[:player_name]} stays."
  @player_buttons = false
  erb :game
end