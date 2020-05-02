# frozen_string_literal: true

require "test_helper"

class ReferenceStocksTest < Minitest::Test
  def setup
    @client = Polygonio::Rest::Client.new(api_key)
  end

  def test_splits
    VCR.use_cassette("reference_stocks_splits") do
      res = @client.reference.stocks.splits("AAPL")
      assert_equal 3, res.results.length
      assert_equal "AAPL", res.results.first.ticker
    end
  end

  def test_dividends
    VCR.use_cassette("reference_stocks_dividends") do
      res = @client.reference.stocks.dividends("AAPL")
      assert_equal 60, res.results.length
      assert_equal "AAPL", res.results.first.ticker
    end
  end

  def test_financials
    VCR.use_cassette("reference_stocks_financials") do
      res = @client.reference.stocks.financials("AAPL")
      assert_equal 415, res.results.length
      assert_equal "AAPL", res.results.first.fetch("ticker")
    end
  end
end
