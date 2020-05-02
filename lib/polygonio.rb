# frozen_string_literal: true

require "polygonio/version"

require "eventmachine"
require "faraday"
require "faraday_middleware"
require "faraday_middleware/parse_oj"
require "dry-struct"
require "dry-types"
require "permessage_deflate"
require "websocket/driver"

require "polygonio/types"
require "polygonio/rest"
require "polygonio/websocket"
