# frozen_literal_string: true

require "test_helper"
require "sea_shanty/configuration"
require "sea_shanty/request_store"
require "sea_shanty/faraday/middleware"

module SeaShanty
  module Faraday
    class TestMiddleware < Minitest::Test
      def setup
        # Faraday stuff
        @faraday_request = build_faraday_request
        @faraday_response = build_faraday_response(@faraday_request)
        @app = build_app(responds_to_close: true, response: @faraday_response)

        # SeaShanty stuff
        dir = Dir.mktmpdir("sea_shanty")
        configuration = Configuration.new
        configuration.storage_dir = Pathname.new(dir)
        @request_store = RequestStore.new(configuration)
        @sea_shanty_request = Request.new(
          method: @faraday_request.method,
          url: @faraday_request.url,
          headers: @faraday_request.request_headers.to_h,
          body: @faraday_request.request_body
        )
        @sea_shanty_response = Response.new(
          status: @faraday_response.env.status,
          message: @faraday_response.env.reason_phrase,
          headers: @faraday_response.env.response_headers.to_h,
          body: @faraday_response.env.response_body
        )

        @middleware = Middleware.new(@app, request_store: @request_store)
      end

      def test_call_calls_the_app
        @middleware.call(@faraday_request)
        assert_equal(@faraday_request, @app.last_request)
      end

      def test_call_returns_the_response_from_the_app
        response = @middleware.call(@faraday_request)
        assert_response(@faraday_response, response)
      end

      def test_call_does_not_call_app_when_request_is_known
        @request_store.store(@sea_shanty_request, @sea_shanty_response)
        @middleware.call(@faraday_request)
        assert_nil(@app.last_request)
      end

      def test_call_returns_a_faraday_response_when_request_is_known
        @request_store.store(@sea_shanty_request, @sea_shanty_response)
        response = @middleware.call(@faraday_request)
        assert_response(@faraday_response, response)
      end

      def test_close_calls_app_close
        app = build_app(responds_to_close: true, response: @faraday_response)
        middleware = Middleware.new(app)
        middleware.close
        assert_predicate(app, :closed?)
      end

      def test_close_does_not_call_app_close
        app = build_app(responds_to_close: false, response: @faraday_response)
        middleware = Middleware.new(app)
        middleware.close
        refute_predicate(app, :closed?)
      end

      def test_it_has_a_request_store
        Middleware.request_store = @request_store
        middleware = Middleware.new(build_app(responds_to_close: true, response: @faraday_response))
        assert_same(@request_store, middleware.request_store)
      end

      private

      def assert_response(expected, actual)
        assert_equal(expected.env.status, actual.env.status)
        assert_equal(expected.env.response_headers, actual.env.response_headers)
        assert_equal(expected.env.response_body, actual.env.response_body)
      end

      class DummyApp
        attr_accessor :last_request

        def initialize(response)
          @response = response
        end

        def call(request)
          self.last_request = request
          response
        end

        def close
          @closed = true
        end

        def closed?
          @closed
        end

        private

        attr_reader :response
      end

      def build_app(responds_to_close:, response:)
        klass = if responds_to_close
          DummyApp
        else
          Class.new(DummyApp) do
            def respond_to?(method)
              if method != :close
                super(method)
              else
                false
              end
            end
          end
        end

        klass.new(response)
      end

      def build_faraday_request
        ::Faraday::Request
          .create(:get) do |req|
            req.headers = ::Faraday::Utils::Headers.new
            req.params = ::Faraday::Utils::ParamsHash.new
            req.options = ::Faraday::ConnectionOptions.from(nil).request
            req.url("https://example.com")
          end
          .to_env(::Faraday::Connection.new)
      end

      def build_faraday_response(request_env)
        response = request_env.response = ::Faraday::Response.new
        request_env.status = 200
        request_env.reason_phrase = "OK"
        request_env.response_headers = ::Faraday::Utils::Headers.from({})
        request_env.response_body = "response body"
        response.finish(request_env)
      end
    end
  end
end
