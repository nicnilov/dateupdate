require 'highline/import'
require_relative 'dateupdate/logging'
require_relative 'dateupdate/auth'

module DateUpdate
  def self.display_welcome
    say ("===========================================================\n"\
         "            Flickr date taken fixing script                \n"\
         '===========================================================')
  end

  def self.start
    display_welcome
    consumer_key = ask('Enter consumer key: ')
    consumer_secret = ask('Enter consumer secret: ')
    auth = DateUpdate::Auth.new(consumer_key, consumer_secret)
    auth.request_token
    true
  end
end

begin
  DateUpdate.start ? ask('Finished successfully') : ask('Error')
rescue => error
  include Logging
  logger.error("Exception: #{error.message}\n\n#{error.backtrace}")
  ask('Error')
end
