require 'rubygems'
require 'sinatra'
require 'pry'

IMAGES = [
    {title: 'utopia', url: 'http://media.tumblr.com/ccee6264ec66e2b95575fabb758ab6e7/tumblr_inline_mq2vu61W0F1qz4rgp.png'},
    {title: 'druids', url: 'http://24.media.tumblr.com/b037901f8c302fc4368432a102f16442/tumblr_miypxbYWoA1s4040oo1_400.gif'},
    {title: 'purple snow', url: 'http://24.media.tumblr.com/75597f75cec43fa6BLACKJACK_AMOUNTfa8f188ea7ce6e/tumblr_mnb1e14emK1r2lohvo1_500.jpg'}
]



set :sessions, true

BLACKJACK_AMOUNT = 21
DEALER_MININUM_AMOUNT = 17
INITIAL_POT_AMOUNT = 500

helpers do

  def showing_cover
    "<img src='/images/cards/cover.jpg'>"
  end
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
      total -= 10 if total > BLACKJACK_AMOUNT
    end
    total
  end #ends calculating_the_total

  def making_image_element(arr)

    suit = case arr[0]
             when 'H' then
               'hearts'
             when 'D' then
               'diamonds'
             when 'S' then
               'spades'
             when 'C' then
               'clubs'
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

  end # ends making_image_element


  def do_we_have_right_value(value)

    if 0 == value.to_i || value.to_i > INITIAL_POT_AMOUNT
      @error = "This amount should not be $0 and should not be more than $#{INITIAL_POT_AMOUNT}."
      halt erb :betting_page
    end

  end  # ends do_we_have_right_value

  def updating_player_pot(value, switcher)
    if(switcher)

      return session[:player_pot] = session[:player_pot] + value.to_i # do I need to have this return-method ???
    else
    return session[:player_pot] = session[:player_pot] - value.to_i # do I need to have this return-method ???
    end
  end   # ends current_betting_amount

end # ends helper



before do
  @main_btn_visible =  true   # making the main btn:s interact with the card-counter
  @dealer_btn = false    # making the dealer_btn to show up
end

get '/' do
  if ( session[:player_name] )

    # progress to the game
    redirect '/game'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  session[:player_pot] = INITIAL_POT_AMOUNT
  erb :new_player
end


post '/new_player' do

  session[:player_name] = params[:player_name].capitalize
  if session[:player_name].empty? || session[:player_name] =~ /\d/
    @error = "Try again!, you need to enter a proper name, thank you"
    halt erb :new_player

  end
  redirect '/betting_page'
end

get '/betting_page' do
  if session[:player_pot] == 0  # check-point, if the player has some money left?
    redirect '/no_game'
  end
  session[:betting_amount] = nil

  erb :betting_page
end

post '/betting_page' do
  session[:betting_amount] = params[:betting];
  do_we_have_right_value( session[:betting_amount] )
  #binding.pry

  redirect '/game'
end

get '/no_game' do

  erb :no_game
end

get '/game' do

session[:turn] = session[:player_name]

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

  if player_total == BLACKJACK_AMOUNT
    @showing_modal = true
    @success = "Congra #{session[:player_name]}, U win, Your total amount is #{updating_player_pot(session[:betting_amount], true)} !"
    @main_btn_visible = false

  elsif player_total > BLACKJACK_AMOUNT
    @showing_modal = true
    @error = "Sorry, but it seems like #{session[:player_name]} loses, You have #{updating_player_pot(session[:betting_amount], false)}."
    @main_btn_visible = false
  end

  erb :game

end # ends hit:btn

post '/game/player/stay' do

  @success = "#{session[:player_name]} has chosen to stay."
  #@main_btn_visible = false

  redirect '/game/dealer'

end # ends stay:btn


get '/game/dealer' do
  session[:turn] = 'dealer'

  @main_btn_visible = false

  dealer_total = calculating_the_total( session[:dealer_cards] )

  if dealer_total == BLACKJACK_AMOUNT
    @showing_modal = true
    @success = "Dealer hit blackjack!, your current pot-amount is #{updating_player_pot(session[:betting_amount], false)} "

  elsif dealer_total > BLACKJACK_AMOUNT
    @showing_modal = true

    @error = "Dealer is busted, your current pot-amount is #{updating_player_pot(session[:betting_amount], true)}"

  elsif dealer_total  >= DEALER_MININUM_AMOUNT
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

  if dealer_total > player_total
    @showing_modal = true

    @error = "Sorry Dealer wins. Your current pot-amount is #{updating_player_pot(session[:betting_amount], false)
    }"
  elsif  dealer_total < player_total
    @showing_modal = true

    @success = "Congratualtions you win, Your current pot-amount is #{updating_player_pot(session[:betting_amount], true)
    }"
  else
    @showing_modal = true

    @success = "It's a tie!!"
  end

  erb :game
end

get '/game_over' do
  erb :game_over
end




