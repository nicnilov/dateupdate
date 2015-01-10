require 'highline/import'
require_relative 'dateupdate/logging'

module DateUpdate
  def self.display_welcome
    say ("===========================================================\n"\
         "            Flickr date taken fixing script                \n"\
         '===========================================================')
  end

  def self.start
    display_welcome
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
