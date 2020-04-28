# frozen_string_literal: true

require "test_helper"

class TickersTest < Minitest::Test
  def setup
    @client = PolygonClient::Rest::Client.new(api_key)
  end

  def teardown; end

  def test_list
    VCR.use_cassette("tickers") do
      res = @client.tickers.list
      assert_equal 1, res.page
      assert_equal 50, res.perPage
      assert_equal 81_972, res.count
      assert_equal 50, res.tickers.length
      assert_equal "A", res.tickers.first.ticker
    end
  end

  def test_types
    VCR.use_cassette("ticker_types") do
      res = @client.tickers.types
      assert_equal "Common Stock", res.results.types.fetch("CS")
    end
  end

  def test_details
    skip "Need higher plan"

    VCR.use_cassette("ticker_details") do
      res = @client.tickers.details("AAPL")
    end
  end
end
