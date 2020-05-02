# frozen_string_literal: true

require "test_helper"

class ReferenceLocalesTest < Minitest::Test
  def setup
    @client = Polygonio::Rest::Client.new(api_key)
  end

  def teardown; end

  def test_list
    VCR.use_cassette("locales") do
      res = @client.reference.locales.list
      assert_equal "Global", res.results.first.name
    end
  end
end
