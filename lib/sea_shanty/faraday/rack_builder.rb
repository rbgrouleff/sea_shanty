# frozen_string_literal: true

require "faraday"
require "sea_shanty/faraday/middleware"

module SeaShanty
  module Faraday
    class RackBuilder < ::Faraday::RackBuilder
      def lock!
        insert_middleware
        super
      end

      private

      def insert_middleware
        return if handlers.any? { |h| h.klass == ::SeaShanty::Faraday::Middleware }
        insert_before(handlers.size, ::SeaShanty::Faraday::Middleware)
      end
    end
  end
end
