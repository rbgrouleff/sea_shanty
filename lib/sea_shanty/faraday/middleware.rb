# frozen_string_literal: true

require "faraday"

require "sea_shanty/request"
require "sea_shanty/response"

module SeaShanty
  module Faraday
    class Middleware
      class << self
        attr_accessor :request_store
      end

      attr_reader :request_store

      def initialize(app, request_store: self.class.request_store)
        @app = app
        @request_store = request_store
      end

      def call(env)
        response = request_store.fetch(build_request(env)) do
          faraday_response = @app.call(env).on_complete do |response_env|
            response_env
          end

          build_response(faraday_response.env)
        end

        build_faraday_response(response, env)
      end

      def close
        @app.close if @app.respond_to?(:close)
      end

      private

      def build_request(env)
        Request.new(method: env.method, url: env.url, headers: env.request_headers.to_h, body: env.request_body)
      end

      def build_response(response_env)
        Response.new(
          status: response_env.status,
          message: response_env.reason_phrase,
          headers: response_env.response_headers.to_h,
          body: response_env.response_body,
          original_response: response_env.response
        )
      end

      def build_faraday_response(response, env)
        if response.was_stored?
          response.original_response
        else
          env.response = ::Faraday::Response.new
          env.status = response.status
          env.reason_phrase = response.message
          env.response_headers = ::Faraday::Utils::Headers.from(response.headers)
          env.response_body = response.body
          env.response.finish(env)
        end
      end
    end
  end
end
