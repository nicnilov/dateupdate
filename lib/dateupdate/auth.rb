require 'httparty'

module DateUpdate
  class Auth

    FLICKR_OAUTH_ROOT = 'https://www.flickr.com/services'
    FLICKR_API_ROOT = 'https://api.flickr.com/services/rest'

    attr_accessor :consumer_key, :consumer_secret, :oauth_token, :oauth_token_secret, :debug_output

    def initialize(consumer_key, consumer_secret)
      @consumer_key = consumer_key.to_s == '' ? ENV['FLICKR_CONSUMER_KEY'] : consumer_key
      @consumer_secret = consumer_secret.to_s == '' ? ENV['FLICKR_CONSUMER_SECRET'] : consumer_secret
    end

    def request_token
      @oauth_token = @oauth_token_secret = nil

      url = "#{FLICKR_OAUTH_ROOT}/oauth/request_token"
      params = sign(:get, url, { oauth_callback: 'oob' })
      response = HTTParty.get(url, debug_output: debug_output, query: params)
      handle_oauth_response(response)
    end

    def user_authorization_url(params = {perms: :write})
      params_norm = normalize_params({oauth_token: @oauth_token}.merge(params))
      url = "#{FLICKR_OAUTH_ROOT}/oauth/authorize/?#{params_norm}"
    end

    def access_token(verifier)
      url = "#{FLICKR_OAUTH_ROOT}/oauth/access_token"
      params = sign(:get, url, { oauth_verifier: verifier })
      response = HTTParty.get(url, debug_output: debug_output, query: params)
      handle_oauth_response(response)
    end

    private

    def nonce
      [OpenSSL::Random.random_bytes(32)].pack('m0').gsub(/\n$/, '')
    end

    def oauth_encode(value)
      value.to_s.encode('utf-8').force_encoding('ascii-8bit') if RUBY_VERSION >= '1.9'
      value.to_s
    end

    def oauth_escape(string)
      oauth_encode(string).gsub(/[^a-zA-Z0-9\-\.\_\~]/) do |special|
        special.unpack('C*').map { |i| sprintf('%%%02X', i) }.join
      end
    end

    def signature(string)
      key = oauth_escape(@consumer_secret) + '&' + oauth_escape(@oauth_token_secret)
      digest = OpenSSL::Digest::SHA1.new
      [OpenSSL::HMAC.digest(digest, key, string)].pack('m0').gsub(/\n$/, '')
    end

    def normalize_params(params)
      params.map { |k, v| oauth_escape(k) + '=' + oauth_escape(v) }.sort.join('&')
    end

    def sign(method, url, params = {})
      query_params = {
        oauth_nonce: nonce,
        oauth_timestamp: Time.now.to_i,
        oauth_consumer_key: @consumer_key,
        oauth_signature_method: 'HMAC-SHA1',
        oauth_version: '1.0'
      }.merge(params)
      query_params[:oauth_token] = @oauth_token unless @oauth_token.nil?

      signature_base = [method.to_s.upcase,
                        oauth_escape(url),
                        oauth_escape(normalize_params(query_params))].join('&')

      query_params[:oauth_signature] = signature(signature_base)
      query_params
    end

    def handle_oauth_response(response)
      if response.success?
        parsed_response = Hash[response.body.split('&').map { |s| s.split('=') }]
        @oauth_token = parsed_response['oauth_token']
        @oauth_token_secret = parsed_response['oauth_token_secret']
        parsed_response
      else
        raise response.body
      end
    end
  end
end
