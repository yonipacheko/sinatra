require 'rubygems'
require 'sinatra'
require 'pry'

IMAGES = [
    {title: 'utopia', url: 'http://media.tumblr.com/ccee6264ec66e2b95575fabb758ab6e7/tumblr_inline_mq2vu61W0F1qz4rgp.png'},
    {title: 'druids', url: 'http://24.media.tumblr.com/b037901f8c302fc4368432a102f16442/tumblr_miypxbYWoA1s4040oo1_400.gif'},
    {title: 'purple snow', url: 'http://24.media.tumblr.com/75597f75cec43fa621fa8f188ea7ce6e/tumblr_mnb1e14emK1r2lohvo1_500.jpg'}
]



set :sessions, true


helpers do
  # CALCULATING THE TOTAL

  def calculating_the_total (cards)
    # [['H', '3'], ['S', 'Q'], ... ]
    arr = cards.map{|e| e[1] }

    total = 0
    arr.each do |value|
      if value == "A"
        total += 11
      elsif value.to_i == 0 # J, Q, K
        total += 10
      else
        total += value.to_i
      end
    end

    #correct for Aces
    arr.select{|e| e == "A"}.count.times do
      total -= 10 if total > 21
    end
    total
  end #ends calculating_the_total

  def making_image_element(arr)

    suit = case arr[0]
             when 'H' then
               'Hearts'
             when 'D' then
               'Diamonds'
             when 'S' then
               'Spades'
             when 'C' then
               'Clubs'
           end

    face_value = arr[1]
    if ['Q', 'H', 'J', 'K', 'A'].include?(face_value)
      face_value = case arr[1]

                     when 'J' then
                       'jack'
                     when 'Q' then
                       'queen'
                     when 'K' then
                       'king'
                     when 'H' then
                       'hearts'
                     when 'A' then
                       'ace'
                   end
    end

    "<img src='/images/cards/#{suit}_#{face_value}.jpg'>"

  end #making_image_element



end # ends helper


def is_it_blackjack?
  if  calculating_the_total == 22
      return true
  end
end

before do
  @main_btn_visible =  true   # making the main btn:s interact with the card-counter
  @dealer_btn = false    # making the dealer_btn to show up
end
get '/' do
  if ( session[:player_name] )

    # progress to the game
    redirect '/game'
    p 'OK'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do

  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do

  # VARIABLES

  session[:dealer_cards] = []
  session[:player_cards] = []


  suits = ['H', 'D', 'S', 'C']
  cards = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']

  session[:deck] = suits.product(cards).shuffle!

  # DEALING CARDS

  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop



  erb :game
end

post '/game/player/hit' do

  session[:player_cards] << session[:deck].pop
  #binding.pry
  player_total = calculating_the_total(session[:player_cards])
  if ( player_total == 21)
    @success = "Congra #{session[:player_name]}, U win, U hit blackjack!"
  elsif (player_total > 21)
    @error = "Sorry, but it seems like #{session[:player_name]} is busted"
    @main_btn_visible = false
  end

  erb :game

end # ends hit:btn

post '/game/player/stay' do
  @success = "#{session[:player_name]} has chosen to stay."
  @main_btn_visible = false

  redirect '/game/dealer'
 # erb :game

end # ends stay:btn


get '/game/dealer' do
  @main_btn_visible = false

  dealer_total = calculating_the_total( session[:dealer_cards] )

  if dealer_total == 21
    @success = "Dealer hit blackjack!"
  elsif dealer_total > 21
    @error = "Dealer is busted, you win"
  elsif dealer_total  >= 17
    redirect '/game/dealer/compare'
  else
    @dealer_btn = true
  end

  erb :game
end

post '/game/dealer/next_card' do

  session[:dealer_cards] << session[:deck].pop
  redirect 'game/dealer'
end # ends next_card


get '/game/dealer/compare' do

  @main_btn_visible = false


  dealer_total = calculating_the_total( session[:dealer_cards])
  player_total = calculating_the_total( session[:player_cards])

  if ( dealer_total > player_total )
    @success = "Sorry Dealer wins."
  elsif ( dealer_total < player_total )
    @success = "Congratualtions you win"
  else
    @success = "It's a tie!!"
  end

  erb :game
end



