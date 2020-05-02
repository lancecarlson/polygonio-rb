# frozen_string_literal: true

module Polygonio
  module Rest
    class PolygonResponse < Dry::Struct
      NUMBERS_TO_WORDS = {
        "10" => "ten",
        "9" => "nine",
        "8" => "eight",
        "7" => "seven",
        "6" => "six",
        "5" => "five",
        "4" => "four",
        "3" => "three",
        "2" => "two",
        "1" => "one"
      }.freeze

      transform_keys do |k|
        k = NUMBERS_TO_WORDS[k] if NUMBERS_TO_WORDS.key?(k)
        k = k.underscore unless k.length == 1
        k.to_sym
      end
    end
  end
end

require_relative "api/crypto"
require_relative "api/forex"
require_relative "api/stocks"
require_relative "api/reference/locales"
require_relative "api/reference/markets"
require_relative "api/reference/stocks"
require_relative "api/reference/tickers"
