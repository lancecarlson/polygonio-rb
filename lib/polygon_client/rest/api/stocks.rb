# frozen_string_literal: true

module PolygonClient
  module Rest
    class Stocks < PolygonRestHandler
      class StockExchange < PolygonResponse
        attribute :id, Types::Integer
        attribute :type, Types::String
        attribute :market, Types::String
        attribute? :mic, Types::String
        attribute :name, Types::String
        attribute? :tape, Types::String
      end

      def list_exchanges
        res = client.request.get("/v1/meta/exchanges")
        Types::Array.of(StockExchange)[res.body]
      end

      class HistoricTradesResponse < PolygonResponse
        attribute :results_count, Types::Integer
        attribute :db_latency, Types::Integer
        attribute :success, Types::Bool
        attribute :ticker, Types::String
        attribute :map, Types::Hash
        attribute :results, Types::Array do
          attribute? :T, Types::String # Not receiving for some reason
          attribute :t, Types::Integer
          attribute :y, Types::Integer
          attribute? :f, Types::Integer
          attribute :q, Types::Integer
          attribute :i, Types::String
          attribute :x, Types::Integer
          attribute :s, Types::Integer
          attribute :c, Types::Array.of(Types::Integer)
          attribute :p, Types::JSON::Decimal
          attribute :z, Types::Integer
        end
      end

      class HistoricParams < Dry::Struct
        attribute? :timestamp, Types::Integer
        attribute? :timestampLimit, Types::Integer # TODO: change to underscore?
        attribute? :reverse, Types::Bool
        attribute? :limit, Types::Integer
      end

      def historic_trades(ticker, date, params = {})
        ticker = Types::String[ticker]
        date = Types::JSON::Date[date]
        params = HistoricParams[params]

        res = client.request.get("/v2/ticks/stocks/trades/#{ticker}/#{date}", params.to_h)
        HistoricTradesResponse[res.body]
      end

      class HistoricQuotesResponse < PolygonResponse
        attribute :results_count, Types::Integer
        attribute :db_latency, Types::Integer
        attribute :success, Types::Bool
        attribute :ticker, Types::String
        attribute :map, Types::Hash
        attribute :results, Types::Array do
          attribute? :T, Types::String # Not receiving for some reason
          attribute :t, Types::Integer
          attribute :y, Types::Integer
          attribute? :f, Types::Integer
          attribute :q, Types::Integer
          attribute? :i, Types::Array.of(Types::Integer)
          attribute :p, Types::JSON::Decimal
          attribute :x, Types::Integer
          attribute :s, Types::Integer
          attribute? :P, Types::JSON::Decimal
          attribute? :X, Types::Integer
          attribute? :S, Types::Integer
          attribute :c, Types::Array.of(Types::Integer)
          attribute :z, Types::Integer
        end
      end

      def historic_quotes(ticker, date, params)
        ticker = Types::String[ticker]
        date = Types::JSON::Date[date]
        params = HistoricParams[params]

        res = client.request.get("/v2/ticks/stocks/nbbo/#{ticker}/#{date}", params.to_h)
        HistoricQuotesResponse[res.body]
      end

      class LastTradeResponse < PolygonResponse
        attribute :status, Types::String
        attribute :symbol, Types::String
        attribute :last do
          attribute :price, Types::JSON::Decimal
          attribute :size, Types::Integer
          attribute :exchange, Types::Integer
          attribute :cond1, Types::Integer
          attribute :cond2, Types::Integer
          attribute :cond3, Types::Integer
          attribute? :cond4, Types::Integer
          attribute :timestamp, Types::Integer
        end
      end

      def last_trade(symbol)
        symbol = Types::String[symbol]

        res = client.request.get("/v1/last/stocks/#{symbol}")
        LastTradeResponse[res.body]
      end

      class LastQuoteResponse < PolygonResponse
        attribute :status, Types::String
        attribute :symbol, Types::String
        attribute :last do
          attribute :askprice, Types::JSON::Decimal
          attribute :asksize, Types::Integer
          attribute :askexchange, Types::Integer
          attribute :bidprice, Types::JSON::Decimal
          attribute :bidsize, Types::Integer
          attribute :bidexchange, Types::Integer
          attribute :timestamp, Types::Integer
        end
      end

      def last_quote(symbol)
        symbol = Types::String[symbol]

        res = client.request.get("/v1/last_quote/stocks/#{symbol}")
        LastQuoteResponse[res.body]
      end

      class DailyOpenCloseResponse < PolygonResponse
        attribute :status, Types::String
        attribute :symbol, Types::String
        attribute :open, Types::JSON::Decimal
        attribute :high, Types::JSON::Decimal
        attribute :low, Types::JSON::Decimal
        attribute :close, Types::JSON::Decimal
        attribute :volume, Types::Integer
        attribute :after_hours, Types::JSON::Decimal
        attribute :from, Types::JSON::DateTime
      end

      def daily_open_close(symbol, date)
        symbol = Types::String[symbol]
        date = Types::JSON::Date[date]

        res = client.request.get("/v1/open-close/#{symbol}/#{date}")
        DailyOpenCloseResponse[res.body]
      end

      def condition_mappings(tick_type)
        tick_type = Types::String.enum("trades", "quotes")[tick_type]

        res = client.request.get("/v1/meta/conditions/#{tick_type}")
        Types::Hash[res.body]
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
          attribute? :c1, Types::Integer
          attribute? :c2, Types::Integer
          attribute? :c3, Types::Integer
          attribute? :c4, Types::Integer
          attribute? :e, Types::Integer
          attribute :p, Types::JSON::Decimal
          attribute :s, Types::Integer
          attribute :t, Types::Integer
        end
        attribute :last_quote do
          attribute :p, Types::JSON::Decimal
          attribute :s, Types::Integer
          attribute? :P, Types::JSON::Decimal
          attribute? :S, Types::Integer
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
        res = client.request.get("/v2/snapshot/locale/us/markets/stocks/tickers")
        FullSnapshotResponse[res.body]
      end

      class SnapshotResponse < PolygonResponse
        attribute :status, Types::String
        attribute :ticker, SnapshotTicker
      end

      def snapshot(ticker)
        ticker = Types::String[ticker]

        res = client.request.get("/v2/snapshot/locale/us/markets/stocks/tickers/#{ticker}")
        SnapshotResponse[res.body]
      end

      class SnapshotGainersLosersResponse < PolygonResponse
        attribute :status, Types::String
        attribute :tickers, Types::Array.of(SnapshotTicker)
      end

      def snapshot_gainers_losers(direction)
        direction = Types::String.enum("gainers", "losers")[direction]

        res = client.request.get("/v2/snapshot/locale/us/markets/stocks/#{direction}")
        SnapshotGainersLosersResponse[res.body]
      end

      class PreviousCloseResponse < PolygonResponse
        attribute :ticker, Types::String
        attribute :status, Types::String
        attribute :adjusted, Types::Bool
        attribute :query_count, Types::Integer
        attribute :results_count, Types::Integer
        attribute :results, Types::Array do
          attribute :T, Types::String
          attribute :v, Types::JSON::Decimal
          attribute :vw, Types::JSON::Decimal
          attribute :o, Types::JSON::Decimal
          attribute :c, Types::JSON::Decimal
          attribute :h, Types::JSON::Decimal
          attribute :l, Types::JSON::Decimal
          attribute :t, Types::Integer
          attribute? :n, Types::Integer
        end
      end

      def previous_close(ticker, unadjusted = false)
        ticker = Types::String[ticker]
        unadjusted = Types::Bool[unadjusted]

        res = client.request.get("/v2/aggs/ticker/#{ticker}/prev", { unadjusted: unadjusted })
        PreviousCloseResponse[res.body]
      end

      class AggregatesResponse < PolygonResponse
        attribute :ticker, Types::String
        attribute :status, Types::String
        attribute :adjusted, Types::Bool
        attribute :query_count, Types::Integer
        attribute :results_count, Types::Integer
        attribute :results, Types::Array do
          attribute? :T, Types::String # Not appearing
          attribute :v, Types::JSON::Decimal
          attribute :vw, Types::JSON::Decimal
          attribute :o, Types::JSON::Decimal
          attribute :c, Types::JSON::Decimal
          attribute :h, Types::JSON::Decimal
          attribute :l, Types::JSON::Decimal
          attribute :t, Types::Integer
          attribute? :n, Types::Integer
        end
      end

      def aggregates(ticker, multiplier, timespan, from, to, unadjusted = false) # rubocop:disable Metrics/ParameterLists
        ticker = Types::String[ticker]
        multiplier = Types::Integer[multiplier]
        timespan = Types::Coercible::String.enum("minute", "hour", "day", "week", "month", "quarter", "year")[timespan]
        from = Types::JSON::Date[from]
        to = Types::JSON::Date[to]
        unadjusted = Types::Bool[unadjusted]

        res = client.request.get("/v2/aggs/ticker/#{ticker}/range/#{multiplier}/#{timespan}/#{from}/#{to}", { unadjusted: unadjusted })
        AggregatesResponse[res.body]
      end

      class GroupedDailyResponse < PolygonResponse
        attribute? :ticker, Types::String
        attribute :status, Types::String
        attribute :adjusted, Types::Bool
        attribute :query_count, Types::Integer
        attribute :results_count, Types::Integer
        attribute :results, Types::Array do
          attribute :T, Types::String # Not appearing
          attribute :v, Types::JSON::Decimal
          attribute? :vw, Types::JSON::Decimal
          attribute :o, Types::JSON::Decimal
          attribute :c, Types::JSON::Decimal
          attribute :h, Types::JSON::Decimal
          attribute :l, Types::JSON::Decimal
          attribute :t, Types::Integer
          attribute? :n, Types::Integer
        end
      end

      def grouped_daily(locale, market, date, unadjusted = false)
        locale = Types::String[locale]
        market = Types::Coercible::String.enum("stocks", "crypto", "bonds", "mf", "mmf", "indices", "fx")[market]
        date = Types::JSON::Date[date]
        unadjusted = Types::Bool[unadjusted]

        res = client.request.get("/v2/aggs/grouped/locale/#{locale}/market/#{market.upcase}/#{date}", { unadjusted: unadjusted })
        GroupedDailyResponse[res.body]
      end
    end
  end
end
