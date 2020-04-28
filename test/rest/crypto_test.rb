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
end
