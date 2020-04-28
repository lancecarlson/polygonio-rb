module PolygonClient
  module Rest
    class Markets < PolygonRestHandler
      class MarketsResponse < PolygonResponse
        attribute :status, Types::String
        attribute :results, Types::Array do
          attribute :market, Types::String
          attribute :desc, Types::String
        end
      end

      def list
        res = client.request.get("/v2/reference/markets")
        MarketsResponse[res.body]
      end

      class MarketStatusResponse < PolygonResponse
        attribute :market, Types::String
        attribute :serverTime, Types::String
        attribute :exchanges do
          attribute :nyse, Types::String
          attribute :nasdaq, Types::String
          attribute :otc, Types::String
        end
        attribute :currencies do
          attribute :fx, Types::String
          attribute :crypto, Types::String
        end
      end

      def status
        res = client.request.get("/v1/marketstatus/now")
        MarketStatusResponse[res.body]
      end

      class MarketHolidaysResponse < PolygonResponse
        attribute :exchange, Types::String
        attribute :name, Types::String
        attribute :status, Types::String
        attribute :date, Types::JSON::DateTime
        attribute? :open, Types::JSON::DateTime
        attribute? :close, Types::JSON::DateTime
      end

      def holidays
        res = client.request.get("/v1/marketstatus/upcoming")
        Types::Array.of(MarketHolidaysResponse)[res.body]
      end
    end
  end
end
