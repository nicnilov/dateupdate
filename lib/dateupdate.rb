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
    repeat do
      albums = @flickr.list_albums
      selected_album = select_album(albums)
      selected_local_dir = select_local_dir
      album_videos = @flickr.list_album_videos(selected_album['id'])
      matching_files = match_local_files(selected_local_dir, album_videos)
      update_dates(matching_files)
      ask('Continue with another album? (y/n) :') == 'y'
    end
  end

  private

  def self.select_album(albums)
    albums.each_with_index { |album, index| say("#{index + 1}: '#{album['title']['_content']}'") }
    album_number = 0
    repeat do
      album_number = ask('Enter the number of a Flickr album to process: ')
      album_number.to_i < 1 || album_number.to_i > albums.size
    end
    albums[album_number.to_i - 1]
  end

  def self.select_local_dir
    local_dir = ''
    repeat do
      local_dir = ask('Enter the local path to the directory containing original files: ')
      !Dir.exists?(local_dir)
    end
    File.join(local_dir, '')
  end

  def self.match_local_files(local_dir, album_videos)
    local_files = Dir.glob(File.join(local_dir, "*.{mts,mov,mp4,avi}"), File::FNM_CASEFOLD).collect do |filepath|
      filename = filepath[/.+\/(.+)\./, 1]
      video = album_videos.find { |av| av['title'].downcase == filename.downcase }
      unless video.nil?
        {
          video_id: video['id'],
          filename: filename,
          last_modified: File.mtime(filepath).to_i
        }
      end
    end.compact
  end

  def self.update_dates(matching_files)
    if matching_files.size > 0
      if ask("Found #{matching_files.size} matching files. Update dates on Flickr? (y/n):") == 'y'
        matching_files.each do |file|
          say("Setting timestamp of #{file[:filename]} to #{Time.at(file[:last_modified]).to_s}")
          @flickr.set_modified_date(file[:video_id], file[:last_modified])
        end
      end
    else
      say('No matching files found')
    end
  end

  def self.repeat(&block)
    more = true
    while more do
      more = yield
    end
  end
end

begin
  DateUpdate.execute
  say('Finished successfully')
rescue => error
  say("Exception: #{error.message}\n\n#{error.backtrace}")
end
