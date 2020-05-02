# frozen_string_literal: true

module Polygonio
  module Websocket
    module Errors
      class PolygonWebsocketClientError < StandardError; end

      class AuthTimeoutError < PolygonWebsocketClientError; end
      class NotAuthorizedError < PolygonWebsocketClientError; end
      class UnrecognizedEventError < PolygonWebsocketClientError
        attr_reader :event

        def initialize(message, event)
          super(message)
          @event = event
        end
      end
    end
  end
end
