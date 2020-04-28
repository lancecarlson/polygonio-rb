# frozen_string_literal: true

require "polygon_client/version"

require "eventmachine"
require "faraday"
require "faraday_middleware"
require "faraday_middleware/parse_oj"
require "dry-struct"
require "dry-types"
require "permessage_deflate"
require "websocket/driver"

require "polygon_client/types"
require "polygon_client/rest"
require "polygon_client/websocket"
