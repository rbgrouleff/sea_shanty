# frozen_string_literal: true

require "test_helper"
require "fileutils"
require "sea_shanty/configuration"
require "sea_shanty/request_store"

require "sea_shanty/faraday/interceptor"

module SeaShanty
  module Faraday
    class TestInterceptor < Minitest::Test
      def setup
        @configuration = Configuration.new
        @configuration.storage_dir = Dir.mktmpdir("sea_shanty")
        @request_store = RequestStore.new(@configuration)
        @interceptor = Interceptor.new
      end

      def teardown
        FileUtils.remove_entry(@configuration.storage_dir)
      end

      def test_intercept_sets_the_middleware_request_store
        @interceptor.intercept!(@request_store)
        assert_same(@request_store, Middleware.request_store)
      end

      def test_intercept_overwrites_the_faraday_connection_options_builder_class
        @interceptor.intercept!(@request_store)
        assert_instance_of(RackBuilder, ::Faraday::ConnectionOptions.from(nil).new_builder(->(_) {}))
      end

      def test_remove_restores_the_builder_class
        @interceptor.intercept!(@request_store)
        @interceptor.remove
        assert_instance_of(::Faraday::RackBuilder, ::Faraday::ConnectionOptions.from(nil).new_builder(->(_) {}))
      end
    end
  end
end
