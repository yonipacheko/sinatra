require 'rubygems'
require 'sinatra'

IMAGES = [
    {title: 'utopia', url: 'http://media.tumblr.com/ccee6264ec66e2b95575fabb758ab6e7/tumblr_inline_mq2vu61W0F1qz4rgp.png'},
    {title: 'druids', url: 'http://24.media.tumblr.com/b037901f8c302fc4368432a102f16442/tumblr_miypxbYWoA1s4040oo1_400.gif'},
    {title: 'purple snow', url: 'http://24.media.tumblr.com/75597f75cec43fa621fa8f188ea7ce6e/tumblr_mnb1e14emK1r2lohvo1_500.jpg'}
]


set :sessions, true

get '/' do
  'it\'s working!'

end

get '/pictures' do
  @images = IMAGES
  erb :my_album
end
