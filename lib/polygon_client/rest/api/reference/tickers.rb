# frozen_string_literal: true

module PolygonClient
  module Rest
    module Reference
      class Tickers < PolygonRestHandler
        class Ticker < PolygonResponse
          attribute :ticker, Types::String
          attribute :name, Types::String
          attribute :market, Types::String
          attribute :locale, Types::String
          attribute :currency, Types::String
          attribute :active, Types::Bool
          attribute :primary_exch, Types::String
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
          attribute :per_page, Types::Integer
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
            attribute :index_types, Types::Hash
          end
        end

        def types
          res = client.request.get("/v2/reference/types")
          TickerTypesResponse[res.body]
        end

        class TickerDetailsResponse < PolygonResponse
          attribute? :logo, Types::String
          attribute :exchange, Types::String
          attribute :exchange_symbol, Types::String
          attribute :name, Types::String
          attribute :symbol, Types::String
          attribute? :listdate, Types::JSON::Date
          attribute? :cik, Types::String
          attribute? :bloomberg, Types::String
          attribute? :figi, Types::String.optional
          attribute? :lie, Types::String
          attribute? :sic, Types::Integer
          attribute? :country, Types::String
          attribute? :industry, Types::String
          attribute? :sector, Types::String
          attribute? :marketcap, Types::Integer
          attribute? :employees, Types::Integer
          attribute? :phone, Types::String
          attribute? :ceo, Types::String
          attribute? :url, Types::String
          attribute? :description, Types::String
          attribute? :similar, Types::Array
          attribute? :tags, Types::Array
          attribute? :hq_address, Types::String
          attribute? :hq_state, Types::String
          attribute? :hq_country, Types::String
          attribute? :active, Types::Bool
          attribute? :updated, Types::String
        end

        def details(symbol)
          symbol = Types::String[symbol]
          res = client.request.get("/v1/meta/symbols/#{symbol}/company")
          TickerDetailsResponse[res.body]
        end

        class NewsResponse < PolygonResponse
          attribute :symbols, Types::Array.of(Types::String)
          attribute :title, Types::String
          attribute :url, Types::String
          attribute :source, Types::String
          attribute :summary, Types::String
          attribute? :image, Types::String
          attribute :timestamp, Types::JSON::DateTime
          attribute :keywords, Types::Array.of(Types::String)
        end

        def news(symbol, page = 1, perpage = 50)
          symbol = Types::String[symbol]
          page = Types::Integer[page]
          perpage = Types::Integer[perpage]
          opts = { page: page, perpage: perpage }

          res = client.request.get("/v1/meta/symbols/#{symbol}/news", opts)
          Types::Array.of(NewsResponse)[res.body]
        end
      end
    end
  end
end
