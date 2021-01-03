# frozen_string_literal: true

module Polygonio
  module Rest
    class Client
      Struct.new("Reference", :locales, :markets, :stocks, :tickers)

      BASE_URL = "https://api.polygon.io/"

      attr_reader :url, :api_key

      def initialize(api_key, &block)
        @url = BASE_URL
        @api_key = Types::String[api_key]
        @request_builder = block if block_given?
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
          @request_builder&.call(builder)
          builder.request :json
          builder.response :oj
          builder.adapter Faraday.default_adapter
        end
      end

      def reference
        Struct::Reference.new(
          Rest::Reference::Locales.new(self),
          Rest::Reference::Markets.new(self),
          Rest::Reference::Stocks.new(self),
          Rest::Reference::Tickers.new(self)
        )
      end

      def stocks
        Rest::Stocks.new(self)
      end

      def forex
        Rest::Forex.new(self)
      end

      def crypto
        Rest::Crypto.new(self)
      end
    end

    class PolygonRestHandler
      attr_reader :client

      def initialize(client)
        @client = client
      end
    end

    class PagingParameters < Dry::Struct
      attribute? :offset, Types::Integer.optional
      attribute? :limit, Types::Integer.default(100)
    end
  end
end
