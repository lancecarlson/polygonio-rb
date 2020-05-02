# frozen_string_literal: true

require "test_helper"

class StocksTest < Minitest::Test
  def setup
    @client = Polygonio::Rest::Client.new(api_key)
  end

  def test_list_exchanges
    VCR.use_cassette("stocks_list_exchanges") do
      res = @client.stocks.list_exchanges
      assert_equal 34, res.length
      assert_equal "Multiple", res.first.name
    end
  end

  def test_historic_trades
    VCR.use_cassette("stocks_historic_trades") do
      res = @client.stocks.historic_trades("AAPL", "2020-04-20", { limit: 500 })
      assert_equal 500, res.results.length
      assert_equal "AAPL", res.ticker
    end
  end

  def test_historic_quotes
    VCR.use_cassette("stocks_historic_quotes") do
      res = @client.stocks.historic_quotes("AAPL", "2020-04-20", { limit: 500 })
      assert_equal 500, res.results.length
      assert_equal "AAPL", res.ticker
    end
  end

  def test_last_trade
    VCR.use_cassette("stocks_last_trade") do
      res = @client.stocks.last_trade("AAPL")
      assert_equal "AAPL", res.symbol
      assert_equal 290.37, res.last.price
    end
  end

  def test_last_quote
    VCR.use_cassette("stocks_last_quote") do
      res = @client.stocks.last_quote("AAPL")
      assert_equal "AAPL", res.symbol
      assert_equal 290.25, res.last.askprice
    end
  end

  def test_daily_open_close
    VCR.use_cassette("stocks_daily_open_close") do
      res = @client.stocks.daily_open_close("AAPL", "2018-03-02")
      assert_equal "AAPL", res.symbol
      assert_equal 174.37, res.open
    end
  end

  def test_conditional_mapping
    VCR.use_cassette("stocks_condition_mappings_trades") do
      res = @client.stocks.condition_mappings("trades")
      assert_equal "Errored", res.fetch("54")
    end
    VCR.use_cassette("stocks_condition_mappings_quotes") do
      res = @client.stocks.condition_mappings("quotes")
      assert_equal "SlowDueLRPBidAsk", res.fetch("71")
    end
  end

  def test_full_snapshot
    # skip("uncomment to speed up tests")
    VCR.use_cassette("stocks_full_snapshot") do
      res = @client.stocks.full_snapshot
      assert_equal "NMCI", res.tickers.first.ticker
    end
  end

  def test_snapshot
    VCR.use_cassette("stocks_snapshot") do
      res = @client.stocks.snapshot("AAPL")
      assert_equal "AAPL", res.ticker.ticker
    end
  end

  def test_snapshot_gainers_losers
    VCR.use_cassette("stocks_snapshot_gainers_losers") do
      res = @client.stocks.snapshot_gainers_losers("gainers")
      assert_equal "NTG", res.tickers.first.ticker
    end
  end

  def test_previous_close
    VCR.use_cassette("stocks_previous_close") do
      res = @client.stocks.previous_close("AAPL")
      assert_equal "AAPL", res.results.first.T
    end
  end

  def test_aggregates
    VCR.use_cassette("stocks_aggregates") do
      res = @client.stocks.aggregates("AAPL", 1, :day, "2019-01-01", "2019-02-01")
      assert_equal 21, res.results.length
      assert_equal 37_039_737, res.results.first.v
    end
  end

  def test_grouped_daily
    VCR.use_cassette("stocks_grouped_daily") do
      res = @client.stocks.grouped_daily("US", :stocks, "2019-02-01")
      assert_equal 8374, res.results.length
      assert_equal "PEB", res.results.first.T
    end
  end
end
