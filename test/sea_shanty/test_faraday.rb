# frozen_string_literal: true

require "test_helper"
require "faraday"
require "sea_shanty"
require "sea_shanty/faraday"

module SeaShanty
  class TestFaraday < Minitest::Test
    def setup
      @dir = Dir.mktmpdir("sea_shanty")
      SeaShanty.configure do |config|
        config.storage_dir = @dir
      end

      SeaShanty.intercept(:faraday)
    end

    def teardown
      SeaShanty.remove(:faraday)
      FileUtils.remove_entry(@dir)
    end

    def test_faraday_requests_are_being_stored
      ::Faraday.get("http://httpbingo.org")
      request = SeaShanty::Request.new(method: :get, url: "http://httpbingo.org", headers: {}, body: nil)
      assert_operator(SeaShanty.request_store, :has_response_for?, request)
    end
  end
end
