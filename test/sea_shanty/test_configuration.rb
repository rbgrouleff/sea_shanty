# frozen_string_literal: true

require "test_helper"

module SeaShanty
  class TestConfiguration < Minitest::Test
    def setup
      @configuration = Configuration.new
    end
  end
end
