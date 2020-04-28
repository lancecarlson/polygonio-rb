# frozen_string_literal: true

module PolygonClient
  module Rest
    class Forex < PolygonRestHandler
      class HistoricTicksResponse < PolygonResponse
        attribute? :day, Types::JSON::Date
        attribute? :map, Types::Hash
        attribute? :ms_latency, Types::Integer
        attribute? :status, Types::String
        attribute? :pair, Types::String
        attribute? :type, Types::String
        attribute :ticks, Types::Array do
          attribute? :a, Types::JSON::Decimal     # Asking price
          attribute? :b, Types::JSON::Decimal     # Bidding price
          attribute? :x, Types::Integer           # Exchange ID
          attribute? :t, Types::Integer
        end
      end

      def historic_ticks(from, to, date, opts = {})
        from = Types::String[from]
        to = Types::String[to]
        date = Types::JSON::Date[date]
        opts = PagingParameters[opts]

        res = client.request.get("/v1/historic/forex/#{from}/#{to}/#{date}", opts.to_h)
        HistoricTicksResponse[res.body]
      end

      class CurrencyConversionResponse < PolygonResponse
        attribute :status, Types::String
        attribute :from, Types::String
        attribute :to, Types::String
        attribute :initial_amount, Types::Integer
        attribute :converted, Types::JSON::Decimal
        attribute :last do
          attribute :bid, Types::JSON::Decimal
          attribute :ask, Types::JSON::Decimal
          attribute :exchange, Types::Integer
          attribute :timestamp, Types::Integer
        end
      end

      def convert_currency(from, to, amount, precision = 2)
        from = Types::String[from]
        to = Types::String[to]
        amount = Types::Coercible::Decimal[amount]
        precision = Types::Integer[precision]
        opts = { amount: amount, precision: precision }

        res = client.request.get("/v1/conversion/#{from}/#{to}", opts)
        CurrencyConversionResponse[res.body]
      end

      class LastQuoteResponse < PolygonResponse
        attribute :status, Types::String
        attribute :symbol, Types::String
        attribute :last do
          attribute :bid, Types::JSON::Decimal
          attribute :ask, Types::JSON::Decimal
          attribute :exchange, Types::Integer
          attribute :timestamp, Types::Integer
        end
      end

      def last_quote(from, to)
        from = Types::String[from]
        to = Types::String[to]

        res = client.request.get("/v1/last_quote/currencies/#{from}/#{to}")
        LastQuoteResponse[res.body]
      end

      class SnapshotTicker < PolygonResponse
        attribute :ticker, Types::String
        attribute :day do
          attribute :c, Types::JSON::Decimal
          attribute :h, Types::JSON::Decimal
          attribute :l, Types::JSON::Decimal
          attribute :o, Types::JSON::Decimal
          attribute :v, Types::JSON::Decimal
        end
        attribute :last_quote do
          attribute :a, Types::JSON::Decimal
          attribute :b, Types::JSON::Decimal
          attribute :i, Types::JSON::Decimal
          attribute :x, Types::Integer
          attribute :t, Types::Integer
        end
        attribute :min do
          attribute :c, Types::JSON::Decimal
          attribute :h, Types::JSON::Decimal
          attribute :l, Types::JSON::Decimal
          attribute :o, Types::JSON::Decimal
          attribute :v, Types::JSON::Decimal
        end
        attribute :prev_day do
          attribute :c, Types::JSON::Decimal
          attribute :h, Types::JSON::Decimal
          attribute :l, Types::JSON::Decimal
          attribute :o, Types::JSON::Decimal
          attribute :v, Types::JSON::Decimal
        end
        attribute :todays_change, Types::JSON::Decimal
        attribute :todays_change_perc, Types::JSON::Decimal
        attribute :updated, Types::Integer
      end

      class FullSnapshotResponse < PolygonResponse
        attribute :status, Types::String
        attribute :tickers, Types::Array.of(SnapshotTicker)
      end

      def full_snapshot
        res = client.request.get("/v2/snapshot/locale/global/markets/forex/tickers")
        FullSnapshotResponse[res.body]
      end

      class SnapshotGainersLosersResponse < FullSnapshotResponse; end

      def snapshot_gainers_losers(direction)
        direction = Types::Coercible::String.enum("gainers", "losers")[direction]
        res = client.request.get("/v2/snapshot/locale/global/markets/forex/#{direction}")
        SnapshotGainersLosersResponse[res.body]
      end
    end
  end
end
