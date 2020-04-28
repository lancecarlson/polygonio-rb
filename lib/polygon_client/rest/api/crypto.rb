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

      class LastTradeResponse < PolygonResponse
        attribute :status, Types::String
        attribute :symbol, Types::String
        attribute :last do
          attribute :price, Types::JSON::Decimal
          attribute :size, Types::JSON::Decimal
          attribute :exchange, Types::Integer
          attribute :conditions, Types::Array.of(Types::Integer)
          attribute :timestamp, Types::Integer
        end
        attribute :last_average do
          attribute :avg, Types::JSON::Decimal
          attribute :trades_averaged, Types::Integer
        end
      end

      def last_trade(from, to)
        from = Types::String[from]
        to = Types::String[to]

        res = client.request.get("/v1/last/crypto/#{from}/#{to}")
        LastTradeResponse[res.body]
      end

      class DailyOpenCloseResponse < PolygonResponse
        attribute :symbol, Types::String
        attribute :is_utc, Types::Bool
        attribute :day, Types::JSON::Date
        attribute :open, Types::JSON::Decimal
        attribute :close, Types::JSON::Decimal
        attribute :open_trades, Types::Array do
          attribute? :p, Types::JSON::Decimal
          attribute? :s, Types::JSON::Decimal
          attribute? :x, Types::Integer
          attribute? :c, Types::Array.of(Types::Integer)
          attribute? :t, Types::Integer
        end
        attribute :closing_trades, Types::Array do
          attribute? :p, Types::JSON::Decimal
          attribute? :s, Types::JSON::Decimal
          attribute? :x, Types::Integer
          attribute? :c, Types::Array.of(Types::Integer)
          attribute? :t, Types::Integer
        end
      end

      def daily_open_close(from, to, date)
        from = Types::String[from]
        to = Types::String[to]
        date = Types::JSON::Date[date]

        res = client.request.get("/v1/open-close/crypto/#{from}/#{to}/#{date}")
        DailyOpenCloseResponse[res.body]
      end

      class HistoricTradesResponse < PolygonResponse
        attribute? :day, Types::JSON::Date
        attribute? :map, Types::Hash
        attribute? :ms_latency, Types::Integer
        attribute? :status, Types::String
        attribute? :symbol, Types::String
        attribute? :type, Types::String
        attribute :ticks, Types::Array do
          attribute? :p, Types::JSON::Decimal
          attribute? :s, Types::JSON::Decimal
          attribute? :x, Types::Integer
          attribute? :c, Types::Array.of(Types::Integer)
          attribute? :t, Types::Integer
        end
      end

      class HistoricTradesPagingParameters < Dry::Struct
        attribute? :offset, Types::Integer.optional
        attribute? :limit, Types::Integer.default(100)
      end

      def historic_trades(from, to, date, opts = {})
        from = Types::String[from]
        to = Types::String[to]
        date = Types::JSON::Date[date]
        opts = HistoricTradesPagingParameters[opts]

        res = client.request.get("/v1/historic/crypto/#{from}/#{to}/#{date}", opts.to_h)
        HistoricTradesResponse[res.body]
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
        attribute :last_trade do
          attribute :p, Types::JSON::Decimal
          attribute :s, Types::JSON::Decimal
          attribute :x, Types::Integer
          attribute :c, Types::Array.of(Types::Integer)
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
        res = client.request.get("/v2/snapshot/locale/global/markets/crypto/tickers")
        FullSnapshotResponse[res.body]
      end

      class SnapshotResponse < PolygonResponse
        attribute :status, Types::String
        attribute :ticker, SnapshotTicker
      end

      def snapshot(ticker)
        ticker = Types::String[ticker]
        res = client.request.get("/v2/snapshot/locale/global/markets/crypto/tickers/#{ticker}")
        SnapshotResponse[res.body]
      end

      class SnapshotBookResponse < PolygonResponse
        attribute :status, Types::String
        attribute :data do
          attribute :ticker, Types::String
          attribute :bids, Types::Array do
            attribute :p, Types::JSON::Decimal
            attribute :x do
              PolygonResponse::NUMBERS_TO_WORDS.each do |_n, w|
                attribute? w.to_sym, Types::JSON::Decimal
              end
            end
          end
          attribute :asks, Types::Array do
            attribute :p, Types::JSON::Decimal
            attribute :x do
              PolygonResponse::NUMBERS_TO_WORDS.each do |_n, w|
                attribute? w.to_sym, Types::JSON::Decimal
              end
            end
          end
          attribute :bid_count, Types::JSON::Decimal
          attribute :ask_count, Types::JSON::Decimal
          attribute :spread, Types::JSON::Decimal
          attribute :updated, Types::Integer
        end
      end

      def snapshot_book(ticker)
        ticker = Types::String[ticker]
        res = client.request.get("/v2/snapshot/locale/global/markets/crypto/tickers/#{ticker}/book")
        SnapshotBookResponse[res.body]
      end

      class SnapshotGainersLosersResponse < FullSnapshotResponse; end

      def snapshot_gainers_losers(direction)
        direction = Types::String[direction]
        res = client.request.get("/v2/snapshot/locale/global/markets/crypto/#{direction}")
        SnapshotGainersLosersResponse[res.body]
      end
    end
  end
end
