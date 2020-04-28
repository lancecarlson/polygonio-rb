# frozen_string_literal: true

require "test_helper"

class ForexTest < Minitest::Test
  def setup
    @client = PolygonClient::Rest::Client.new(api_key)
  end

  def teardown; end

  def test_historic
    VCR.use_cassette("historic") do
      res = @client.forex.historic
      pp res
    end
  end
end
