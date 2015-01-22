require 'highline/import'
require_relative 'dateupdate/flickr/flickrapi'

module DateUpdate

  def self.execute
    display_welcome
    consumer_key = ask('Enter consumer key: ')
    consumer_secret = ask('Enter consumer secret: ')
    @flickr = DateUpdate::FlickrApi.new(consumer_key, consumer_secret)
    authenticate unless @flickr.authenticated?
    process_albums
  end

  def self.display_welcome
    say ("===========================================================\n"\
         "            Flickr date taken fixing script                \n"\
         '===========================================================')
  end

  def self.authenticate
    @flickr.request_token
    say("\nGo by this url to authorize this script to access your Flickr account:\n")
    say(@flickr.user_authorization_url + "\n\n")
    verifier = ask('Enter the code given by Flickr: ')
    @flickr.access_token(verifier)
    say("\nSuccessfully authenticated\n")
  end

  def self.process_albums
    more = true
    while more do
      albums = @flickr.list_albums
      @album = select_album(albums)
    end
  end

  def self.select_album(albums)
    albums.keys.each_with_index { |key, index| say("#{index + 1}: '#{albums[key]}'") }
    album_index = ask('Enter the number of a Flickr album to process: ')
    album_key = albums.keys[album_index.to_i - 1]
    album_name = albums[album_key]
    say("Selected album '#{album_name}' (#{album_key})")
    { album_key: album_name }
  end
end

begin
  DateUpdate.execute
  say('Finished successfully')
rescue => error
  say("Exception: #{error.message}\n\n#{error.backtrace}")
end
