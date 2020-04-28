# frozen_string_literal: true

require "test_helper"

class MarketsTest < Minitest::Test
  def setup
    @client = PolygonClient::Rest::Client.new(api_key)
  end

  def teardown; end

  def test_list
    VCR.use_cassette("locales") do
      res = @client.locales.list
      assert_equal "Global", res.results.first.name
    end
  end
end
