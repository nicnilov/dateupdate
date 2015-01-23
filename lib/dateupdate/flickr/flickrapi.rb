require_relative('auth')

module DateUpdate
  class FlickrApi
    include Auth

    FLICKR_API_ROOT = 'https://api.flickr.com/services/rest'

    def initialize(consumer_key, consumer_secret)
      @consumer_key = consumer_key.to_s == '' ? ENV['FLICKR_CONSUMER_KEY'] : consumer_key
      @consumer_secret = consumer_secret.to_s == '' ? ENV['FLICKR_CONSUMER_SECRET'] : consumer_secret
      @oauth_token = ENV['FLICKR_OAUTH_TOKEN']
      @oauth_token_secret = ENV['FLICKR_OAUTH_TOKEN_SECRET']
    end

    def list_albums
      response = api_request(:get, {method: 'flickr.photosets.getList'})
      response['photosets']['photoset']
    end

    def list_album_videos(album_id)
      response = api_request(:get, {method: 'flickr.photosets.getPhotos', photoset_id: album_id, media: 'videos',
                                    extras: 'date_taken'})
      response['photoset']['photo']
    end

    def set_modified_date(photo_id, timestamp)
      response = api_request(:post, {method: 'flickr.photos.setDates', photo_id: photo_id,
                                     date_taken: Time.at(timestamp).strftime('%Y-%m-%d %H:%M:%S'),
                                     date_taken_granularity: 0})
    end

    private

    def api_request(method, params = {})
      params = sign(method, FLICKR_API_ROOT, { format: :json, nojsoncallback: 1 }.merge(params))
      response = HTTParty.send(method, FLICKR_API_ROOT, debug_output: debug_output,
                               method == :get ? :query : :body =>  params)
    end
  end
end
