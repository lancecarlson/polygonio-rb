# frozen_string_literal: true

module PolygonClient
  module Rest
    class Crypto < PolygonRestHandler
      class CryptoExchange < PolygonResponse
        attribute :id, Types::Integer
        attribute :type, Types::String
        attribute :market, Types::String
        attribute :name, Types::String
        attribute :url, Types::String
      end

      def list
        res = client.request.get("/v1/meta/crypto-exchanges")
        Types::Array.of(CryptoExchange)[res.body]
      end
    end
  end
end
