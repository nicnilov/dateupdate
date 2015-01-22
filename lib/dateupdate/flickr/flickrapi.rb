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
      albums = response['photosets']['photoset'].collect { |album| [ album['id'], album['title']['_content'] ] }
      Hash[albums.sort_by(&:last)]
    end

    private

    def api_request(method, params = {})
      params = sign(method, FLICKR_API_ROOT, { format: :json, nojsoncallback: 1 }.merge(params))
      response = HTTParty.send(method, FLICKR_API_ROOT, debug_output: debug_output, query: params)
    end
  end
end
