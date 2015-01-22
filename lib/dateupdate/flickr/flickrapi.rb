require_relative('auth')

module DateUpdate
  class FlickrApi
    include Auth

    def initialize(consumer_key, consumer_secret)
      @consumer_key = consumer_key.to_s == '' ? ENV['FLICKR_CONSUMER_KEY'] : consumer_key
      @consumer_secret = consumer_secret.to_s == '' ? ENV['FLICKR_CONSUMER_SECRET'] : consumer_secret
    end

  end
end
