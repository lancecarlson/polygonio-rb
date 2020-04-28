# frozen_string_literal: true

require "test_helper"

class CryptoTest < Minitest::Test
  def setup
    @client = PolygonClient::Rest::Client.new(api_key)
  end

  def teardown; end

  def test_list
    VCR.use_cassette("cryptos") do
      res = @client.crypto.list
      assert_equal 22, res.length
      assert_equal "GDAX", res.first.name
    end
  end

  def test_last_trade
    VCR.use_cassette("crypto_last_trade") do
      res = @client.crypto.last_trade("BTC", "USD")
      assert_equal "BTC-USD", res.symbol
    end
  end

  def test_daily_open_close
    VCR.use_cassette("crypto_daily_open_close") do
      res = @client.crypto.daily_open_close("BTC", "USD", Date.new(2019, 4, 28))
      assert_equal "BTC-USD", res.symbol
    end
  end

  def test_historic_trades
    offset = nil

    VCR.use_cassette("crypto_historic_trades") do
      res = @client.crypto.historic_trades("BTC", "USD", Date.new(2019, 4, 28))
      assert_equal "BTC-USD", res.symbol
      offset = res.ticks.last.t
    end

    VCR.use_cassette("crypto_historic_trades_with_offset_and_limit") do
      params = { offset: offset, limit: 12 }
      res = @client.crypto.historic_trades("BTC", "USD", Date.new(2019, 4, 28), params)
      assert_equal "BTC-USD", res.symbol
      assert_equal 12, res.ticks.length
    end
  end

  def test_full_snapshot
    VCR.use_cassette("crypto_full_snapshot") do
      res = @client.crypto.full_snapshot
      assert_equal 168, res.tickers.length
    end
  end

  def test_single_snapshot
    VCR.use_cassette("crypto_single_snapshot") do
      res = @client.crypto.snapshot("X:BTCUSD")
      assert_equal "X:BTCUSD", res.ticker.ticker
    end
  end

  def test_snapshot_book
    VCR.use_cassette("crypto_snapshot_book") do
      res = @client.crypto.snapshot_book("X:BTCUSD")
      assert_equal res.data.ticker, "X:BTCUSD"
    end
  end

  def test_gainers_losers
    VCR.use_cassette("crypto_snapshot_gainers_losers") do
      res = @client.crypto.snapshot_gainers_losers("gainers")
      assert_equal 21, res.tickers.length
      assert_equal "X:SNCUSD", res.tickers.first.ticker
    end
  end
end
