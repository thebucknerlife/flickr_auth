require 'sinatra'
require 'flickraw'

KEY = 'df00a7265f15c5a0bbf4ce9b0258b06d'
SECRET = '244082323faf83f6'

FlickRaw.api_key=KEY
FlickRaw.shared_secret=SECRET

flickr_client = FlickRaw::Flickr.new

get '/' do
  @token = flickr_client.get_request_token
  @auth_url = flickr_client.get_authorize_url(@token['oauth_token'], :perms => 'delete')
  erb :home
end

post '/login' do

  # You've never seen this 'begin' syntax before. Basically means that ruby developers
  # can wrap code in a 'begin' block and then 'rescue' specific errors. In this case,
  # if login fails, Flickraw throws an 'FlickRaw::OAuthClient::FailedResponse' error.
  # Instead of letting our app crash we can rescue the error and send the user to 
  # an error page with the error message
  begin
    flickr_client.get_access_token(params['oauth_token'], params['oauth_token_secret'], params['code'])
    @login = flickr_client.test.login
    @flickr = flickr_client

    # At this point, in a Rails app, you should save the access_token and access_secret
    # either in the database (maybe as two different attributes for a User model) or
    # in the cookie (using session - did this with Forecastigram).

    erb :login
  rescue FlickRaw::OAuthClient::FailedResponse => e
    @error = e # 'e' come from the line above.

    erb :error
  end
end

