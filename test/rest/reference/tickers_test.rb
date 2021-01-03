# frozen_string_literal: true

require "test_helper"

class ReferenceTickersTest < Minitest::Test
  def setup
    @client = Polygonio::Rest::Client.new(api_key) do |builder|
      # builder.response :logger, nil, { headers: true, bodies: true }
    end
  end

  def test_list
    VCR.use_cassette("tickers") do
      res = @client.reference.tickers.list
      assert_equal 1, res.page
      assert_equal 50, res.per_page
      assert_equal 122_669, res.count
      assert_equal 50, res.tickers.length
      assert_equal "A", res.tickers.first.ticker
    end

    VCR.use_cassette("tickers_2") do
      res = @client.reference.tickers.list(page: 2)
      assert_equal 2, res.page
    end
  end

  def test_types
    VCR.use_cassette("ticker_types") do
      res = @client.reference.tickers.types
      assert_equal "Common Stock", res.results.types.fetch("CS")
    end
  end

  def test_details
    VCR.use_cassette("ticker_details") do
      res = @client.reference.tickers.details("AAPL")
      assert_equal "Apple Inc.", res.name
    end
  end

  def test_news
    VCR.use_cassette("ticker_news") do
      res = @client.reference.tickers.news("AAPL", 4, 49)
      assert_equal 49, res.length
    end
  end
end
