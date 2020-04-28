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

      class TickerTypesResponse < PolygonResponse
        attribute :status, Types::String
        attribute :results do
          attribute :types, Types::Hash
          attribute :indexTypes, Types::Hash
        end
      end

      def types
        res = client.request.get("/v2/reference/types")
        TickerTypesResponse[res.body]
      end

      class TickerDetailsResponse < PolygonResponse
        attribute? :logo, Types::String
        attribute :exchange, Types::String
        attribute :name, Types::String
        attribute :symbol, Types::String
        attribute :listdate?, Types::String
        attribute :cik?, Types::String
        attribute :bloomberg?, Types::String
        attribute :figi?, Types::String
        attribute :lie?, Types::String
        attribute :sic?, Types::Integer
        attribute :country?, Types::String
        attribute :industry?, Types::String
        attribute :sector?, Types::String
        attribute :marketcap?, Types::Integer
        attribute :employees?, Types::Integer
        attribute :phone?, Types::String
        attribute :ceo?, Types::String
        attribute :url?, Types::String
        attribute :description?, Types::String
        attribute :similar?, Types::Array
        attribute :tags?, Types::Array
        attribute :updated?, Types::String
      end

      def details(symbol)
        symbol = Types::String[symbol]
        res = client.request.get("/v1/meta/symbols/#{symbol}/company")
        TickerDetailsResponse[res.body]
      end
    end
  end
end
