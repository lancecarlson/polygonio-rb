# frozen_string_literal: true

require "test_helper"

class MarketsTest < Minitest::Test
  def setup
    @client = PolygonClient::Rest::Client.new(api_key)
  end

  def teardown; end

  def test_list
    VCR.use_cassette("markets") do
      res = @client.markets.list
      assert_equal "STOCKS", res.results.first.market
    end
  end

  def test_status
    VCR.use_cassette("market_status") do
      res = @client.markets.status
      assert_equal "closed", res.exchanges.nyse
    end
  end

  def test_holidays
    VCR.use_cassette("market_holidays") do
      res = @client.markets.holidays
      assert_equal "Memorial Day", res.first.name
    end
  end
end
