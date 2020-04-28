# frozen_string_literal: true

require "test_helper"

class ForexTest < Minitest::Test
  def setup
    @client = PolygonClient::Rest::Client.new(api_key)
  end

  def teardown; end

  def test_historic
    offset = nil

    VCR.use_cassette("forex_historic_ticks") do
      res = @client.forex.historic_ticks("AUD", "USD", Date.new(2019, 4, 28))
      assert_equal "AUD/USD", res.pair
      offset = res.ticks.last.t
    end

    VCR.use_cassette("forex_historic_ticks_with_offset_and_limit") do
      params = { offset: offset, limit: 12 }
      res = @client.forex.historic_ticks("AUD", "USD", Date.new(2019, 4, 28), params)
      assert_equal "AUD/USD", res.pair
      assert_equal 12, res.ticks.length
    end
  end

  def test_currency_conversion
    VCR.use_cassette("currency_conversion") do
      res = @client.forex.convert_currency("AUD", "USD", 252)
      assert_equal 252, res.initial_amount
    end
  end

  def test_last_quote
    VCR.use_cassette("currency_last_quote") do
      res = @client.forex.last_quote("AUD", "USD")
      assert_equal "AUD/USD", res.symbol
    end
  end

  def test_full_snapshot
    VCR.use_cassette("forex_full_snapshot") do
      res = @client.forex.full_snapshot
      assert_equal "C:MVRUSD", res.tickers.first.ticker
      assert_equal 1260, res.tickers.length
    end
  end

  def test_snapshot_gainers_losers
    VCR.use_cassette("forex_snapshot_gainers_losers") do
      res = @client.forex.snapshot_gainers_losers("gainers")
      assert_equal "C:ZARNGN", res.tickers.first.ticker
      assert_equal 21, res.tickers.length
    end
  end
end
