# frozen_string_literal: true

module PolygonClient
  module Rest
    class Client
      BASE_URL = "https://api.polygon.io/"

      attr_reader :url, :api_key

      def initialize(api_key)
        @url = BASE_URL
        @api_key = Types::String[api_key]
      end

      RETRY_OPTIONS = {
        max: 2,
        interval: 0.05,
        interval_randomness: 0.5,
        backoff_factor: 2,
        exceptions: [Faraday::ConnectionFailed].concat(Faraday::Request::Retry::DEFAULT_EXCEPTIONS)
      }.freeze

      def request
        Faraday.new(url: "#{url}?apiKey=#{api_key}") do |builder|
          builder.request :retry, RETRY_OPTIONS
          builder.use ErrorMiddleware
          builder.request :json
          builder.response :oj
          builder.adapter Faraday.default_adapter
        end
      end

      def tickers
        Rest::Tickers.new(self)
      end
    end

    class PolygonRestRequest < Dry::Struct
      transform_keys(&:to_sym)
    end

    class PolygonRestHandler
      attr_reader :client

      def initialize(client)
        @client = client
      end

      protected

      def parse_response(res, name)
        body = res.body

        raise(Errors::NilResponseError) if body.nil?
        raise(Errors::UnexpectedResponseError, body) if body[name].nil?

        body[name]
      end
    end
  end
end
