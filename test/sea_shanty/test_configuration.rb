# frozen_string_literal: true

require "test_helper"

module SeaShanty
  class TestConfiguration < Minitest::Test
    def setup
      @configuration = Configuration.new
    end

    def test_lets_you_select_http_library
      library = :faraday
      @configuration.http_library = library
      assert_equal(library, @configuration.http_library)
    end
  end
end
