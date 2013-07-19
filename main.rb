require 'rubygems'
require 'sinatra'

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

  def is_it_blackjack?
    if ( calculating_the_total == 21 )
      return true
    end
  end

end


before do
  
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
  #@player_cards << @deck.pop
=begin
  if (!is_it_blackjack?)
       @error = "Sorry, you lose!"
  end
=end

  erb :game
end

post '/game/player/stay' do

end



get '/pictures' do
  @images = IMAGES
  erb :my_album
end


after do

end