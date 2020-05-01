# frozen_string_literal: true

module PolygonClient
  module Rest
    module Reference
      class Stocks < PolygonRestHandler
        class StockSplitsResponse < PolygonResponse
          attribute :status, Types::String
          attribute :count, Types::Integer
          attribute :results, Types::Array do
            attribute :ticker, Types::String
            attribute :ex_date, Types::JSON::Date
            attribute :payment_date, Types::JSON::Date
            attribute? :record_date, Types::JSON::Date
            attribute? :declared_date, Types::JSON::Date
            attribute :ratio, Types::JSON::Decimal
            attribute? :to_factor, Types::Integer
            attribute? :for_factor, Types::Integer
          end
        end

        def splits(symbol)
          res = client.request.get("/v2/reference/splits/#{symbol}")
          StockSplitsResponse[res.body]
        end

        class StockDividendsResponse < PolygonResponse
          attribute :status, Types::String
          attribute :count, Types::Integer
          attribute :results, Types::Array do
            attribute :ticker, Types::String
            attribute? :type, Types::String
            attribute :ex_date, Types::String
            attribute :payment_date, Types::JSON::Date
            attribute :record_date, Types::JSON::Date
            attribute? :declared_date, Types::JSON::Date
            attribute :amount, Types::JSON::Decimal
            attribute? :qualified, Types::String
            attribute? :flag, Types::String
          end
        end

        def dividends(symbol)
          res = client.request.get("/v2/reference/dividends/#{symbol}")
          StockDividendsResponse[res.body]
        end

        class StockFinancialsResponse < PolygonResponse
          attribute :status, Types::String
          attribute? :count, Types::Integer
          # I'm lazy and didn't want to copy every field here. Please submit PR if you want to crack at it!
          attribute :results, Types::Array.of(Types::Hash)
        end

        class StockFinancialsParameters < Dry::Struct
          attribute? :limit, Types::Integer
          attribute? :type, Types::String.enum("Y", "YA", "Q", "QA", "T", "TA")
          attribute? :sort, Types::String.enum("reportPeriod", "-reportPeriod", "calendarDate", "-calendarDate")
        end

        def financials(symbol, params = {})
          params = StockFinancialsParameters[params]

          res = client.request.get("/v2/reference/financials/#{symbol}", params.to_h)
          StockFinancialsResponse[res.body]
        end
      end
    end
  end
end
