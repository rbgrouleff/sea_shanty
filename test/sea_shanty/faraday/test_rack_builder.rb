# frozen_string_literal: true

require "test_helper"
require "sea_shanty/faraday/rack_builder"

module SeaShanty
  module Faraday
    class TestRackBuilder < Minitest::Test
      def setup
        @rack_builder = RackBuilder.new
      end

      def test_lock_inserts_middleware_last_in_handlers_array
        @rack_builder.lock!
        assert_equal(Middleware, @rack_builder.handlers.last.klass)
      end

      def test_lock_only_inserts_middleware_once
        @rack_builder.lock!
        @rack_builder.lock!
        assert_equal(1, @rack_builder.handlers.count { |h| h.klass == Middleware })
      end
    end
  end
end
