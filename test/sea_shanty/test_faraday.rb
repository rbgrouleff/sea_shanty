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
      FileUtils.remove_entry(@dir)
      SeaShanty.reset!
    end

    def test_faraday_requests_are_being_stored
      ::Faraday.get("http://httpbingo.org")
      request = SeaShanty::Request.new(method: :get, url: "http://httpbingo.org", headers: {}, body: nil)
      path = SeaShanty.request_store.request_file_path(request)
      assert_predicate(path, :exist?)
    end
  end
end
