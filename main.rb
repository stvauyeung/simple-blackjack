require 'rubygems'
require 'sinatra'

set :sessions, true

BLACKJACK = 21
DEALER_MAX_HIT = 17
POT_START_AMT = 500

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
      break if total <= BLACKJACK
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

  def winner!(msg)
    @player_buttons = false
    @success = "<strong>Congratulations, #{session[:player_name]} wins.</strong> #{msg}"
    @next_round = true
    session[:player_pot] = session[:player_pot] + session[:bet_amount]
  end

  def loser!(msg)
    @player_buttons = false
    @error = "<strong>Sorry, #{session[:player_name]} loses.</strong> #{msg}"
    @next_round = true
    session[:player_pot] = session[:player_pot] - session[:bet_amount]
  end

  def push!(msg)
    @player_buttons = false
    @error = "<strong>It's a push.</strong> #{msg}"
    @next_round = true
  end
end

before do
  @player_buttons = true
end

get '/' do
  if session[:player_name]
    redirect '/bet'
  else
    redirect '/form'
  end
end

get '/form' do
  session[:player_pot] = POT_START_AMT
  erb :form
end

post '/form' do
  if params[:player_name].empty?
      @error = "You must enter a name!"
      halt erb(:form)
  end

    session[:player_name] = params[:player_name]
    redirect '/bet'
end

get '/bet' do
  session[:bet_amount] = nil
  erb :bet
end

post '/bet' do
  if params[:bet_amount].nil? || params[:bet_amount].to_i == 0
    @error = "Bets must be placed before the deal"
    halt erb(:bet)
  elsif params[:bet_amount].to_i > session[:player_pot]
    @error = "Your bet exceeds the max amount"
    halt erb(:bet)
  end

  session[:bet_amount] = params[:bet_amount].to_i
  redirect '/game'
end

get '/game' do
  session[:turn] = session[:player_name]

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

  if calculate_total(session[:player_cards]) == BLACKJACK
    redirect '/game/dealer'
  end

  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop

  if calculate_total(session[:player_cards]) > BLACKJACK
    loser!("#{session[:player_name]} busted at #{calculate_total(session[:player_cards])}.")
  elsif calculate_total(session[:player_cards]) == BLACKJACK
    redirect '/game/dealer'
  end
  
  erb :game, layout: false
end

post '/game/player/stay' do
  @success = "#{session[:player_name]} stays at #{calculate_total(session[:player_cards])}."
  redirect '/game/dealer'
end

get '/game/dealer' do
  session[:turn] = 'dealer'
  @player_buttons = false

  dealer_total = calculate_total(session[:dealer_cards])

  if dealer_total >= DEALER_MAX_HIT
    redirect '/game/compare'
  end

  @dealer_buttons = true
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

  if dealer_total > BLACKJACK
     winner!("Dealer has busted.")
  elsif player_total < dealer_total
    loser!("#{session[:player_name]} has #{player_total} to dealer's #{dealer_total}")
  elsif player_total > dealer_total
    winner!("#{session[:player_name]} has #{player_total} to dealer's #{dealer_total}")
  else
    push!("Dealer and #{session[:player_name]} both have #{player_total}.")
  end

  erb :game
end

get '/game_over' do
  erb :game_over
end
