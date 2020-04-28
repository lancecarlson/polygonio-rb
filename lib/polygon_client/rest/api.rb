# frozen_string_literal: true

module PolygonClient
  module Rest
    class PolygonResponse < Dry::Struct
      transform_keys(&:to_sym)
    end
  end
end

require_relative "api/tickers"
