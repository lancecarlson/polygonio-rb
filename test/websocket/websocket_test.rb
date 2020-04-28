# frozen_string_literal: true

require "test_helper"

class WebsocketTest < Minitest::Test
  def setup
    @client = PolygonClient::Websocket::Client.new(api_key)
  end

  def teardown; end
end
