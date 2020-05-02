# frozen_string_literal: true

require "test_helper"

class WebsocketTest < Minitest::Test
  def setup
    @client = Polygonio::Websocket::Client.new(api_key)
  end
end
