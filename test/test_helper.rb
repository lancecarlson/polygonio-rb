# frozen_string_literal: true

ENV["RUBY_ENV"] ||= "test"

require "bundler/setup"
require "dotenv/load"
require "securerandom"
require "faker"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "polygon_client"

require "minitest/autorun"
require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "test/fixtures/vcr_cassettes"
  config.hook_into :faraday
  config.default_cassette_options = {
    match_requests_on: [:method, :uri]
  }
  config.filter_sensitive_data("<API_KEY>") { api_key }
end

VCR.turn_off!(ignore_cassettes: true) if ENV["INTEGRATION_TEST"] == "ON"

def api_key
  ENV.fetch("API_KEY")
end
