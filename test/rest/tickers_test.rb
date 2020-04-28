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
      assert_equal 81_949, res.count
      assert_equal 50, res.tickers.length
      assert_equal "A", res.tickers.first.ticker
    end
  end
end
