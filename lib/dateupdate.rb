require 'highline/import'
require_relative 'dateupdate/flickr/flickrapi'

module DateUpdate

  def self.execute
    display_welcome
    authenticate
  end

  def self.display_welcome
    say ("===========================================================\n"\
         "            Flickr date taken fixing script                \n"\
         '===========================================================')
  end

  def self.authenticate
    consumer_key = ask('Enter consumer key: ')
    consumer_secret = ask('Enter consumer secret: ')
    flickr = DateUpdate::FlickrApi.new(consumer_key, consumer_secret)
    flickr.request_token
    say("\nGo by this url to authorize this script to access your Flickr account:\n")
    say(flickr.user_authorization_url + "\n\n")
    verifier = ask('Enter the code given by Flickr: ')
    flickr.access_token(verifier)
    say("\nSuccessfully authenticated\n")
  end
end

begin
  DateUpdate.execute
  say('Finished successfully')
rescue => error
  say("Exception: #{error.message}\n\n#{error.backtrace}")
end
