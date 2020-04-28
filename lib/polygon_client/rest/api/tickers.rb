# frozen_string_literal: true

module PolygonClient
  module Rest
    class Tickers < PolygonRestHandler
      class Ticker < PolygonResponse
        attribute :ticker, Types::String
        attribute :name, Types::String
        attribute :market, Types::String
        attribute :locale, Types::String
        attribute :currency, Types::String
        attribute :active, Types::Bool
        attribute :primaryExch, Types::String
        attribute? :type, Types::String
        attribute? :codes do
          attribute? :cik, Types::String
          attribute? :figiuid, Types::String
          attribute? :scfigi, Types::String
          attribute? :cfigi, Types::String
          attribute? :figi, Types::String
        end
        attribute :updated, Types::JSON::Date
        attribute :url, Types::String
      end

      class TickerResponse < PolygonResponse
        attribute :page, Types::Integer
        attribute :perPage, Types::Integer
        attribute :count, Types::Integer
        attribute :status, Types::String
        attribute :tickers, Types::Array.of(Ticker)
      end

      class TickersParameters < Dry::Struct
        attribute? :sort, Types::String
        attribute? :type, Types::String
        attribute? :market, Types::String
        attribute? :locale, Types::String
        attribute? :search, Types::String
        attribute? :perpage, Types::String
        attribute? :page, Types::Integer
        attribute? :active, Types::Bool
      end

      def list(params = {})
        params = TickersParameters[params]

        res = client.request.get("/v2/reference/tickers", params.to_h)
        TickerResponse[res.body]
      end
    end
  end
end
