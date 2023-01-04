# frozen_string_literal: true

require "sea_shanty/faraday/middleware"
require "sea_shanty/faraday/rack_builder"

module SeaShanty
  module Faraday
    class Interceptor
      BUILDER_CLASS_ATTR_NAME = :builder_class

      def intercept!(request_store)
        Middleware.request_store = request_store
        ::Faraday::ConnectionOptions.memoized(BUILDER_CLASS_ATTR_NAME) { RackBuilder }
      end

      def remove
        ::Faraday::ConnectionOptions.memoized(BUILDER_CLASS_ATTR_NAME) { ::Faraday::RackBuilder }
      end
    end
  end
end
