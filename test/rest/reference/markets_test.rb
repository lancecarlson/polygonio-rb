# frozen_string_literal: true

require "test_helper"

class ReferenceMarketsTest < Minitest::Test
  def setup
    @client = PolygonClient::Rest::Client.new(api_key)
  end

  def test_list
    VCR.use_cassette("markets") do
      res = @client.reference.markets.list
      assert_equal "STOCKS", res.results.first.market
    end
  end

  def test_status
    VCR.use_cassette("market_status") do
      res = @client.reference.markets.status
      assert_equal "closed", res.exchanges.nyse
    end
  end

  def test_holidays
    VCR.use_cassette("market_holidays") do
      res = @client.reference.markets.holidays
      assert_equal "Memorial Day", res.first.name
    end
  end
end
