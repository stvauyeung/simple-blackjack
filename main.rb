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

    "<img src='/images/cards2/#{suit}_#{card[1]}.png' alt='#{card[1]} of #{suit}' class='card-image'>"
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
  if params[:player_name].empty?
      @error = "You must enter a name!"
      halt erb(:form)
  end

    session[:player_name] = params[:player_name]
    redirect '/game'
end


get '/game' do
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
    redirect '/game/dealer'
  end

  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop

  if calculate_total(session[:player_cards]) > 21
    @error = "Sorry, #{session[:player_name]} has busted."
    @player_buttons = false
  elsif calculate_total(session[:player_cards]) == 21
    @success = "You hit twenty-one!"
    @player_buttons = false
  end
  
  erb :game
end

post '/game/player/stay' do
  @success = "#{session[:player_name]} stays at #{calculate_total(session[:player_cards])}."
  redirect '/game/dealer'
end

get '/game/dealer' do
  @player_buttons = false

  dealer_total = calculate_total(session[:dealer_cards])

  if dealer_total == 21
    @error = "Dealer hit twenty-one."
    redirect '/game/compare'
  elsif dealer_total > 21
    redirect '/game/compare'
  elsif dealer_total >= 17
    # dealer stays
    redirect '/game/compare'
  else
    # dealer hits
    @dealer_buttons = true
  end

  erb :game
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do
  @player_buttons = false

  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])

  if dealer_total > 21
    @success = "Dealer has busted."
  elsif player_total < dealer_total
    @error = "Sorry, dealer wins."
  elsif player_total > dealer_total
    @success = "Congratulations, #{session[:player_name]} wins."
  else
    @success = "Dealer and #{session[:player_name]} push."
  end

  erb :game
end