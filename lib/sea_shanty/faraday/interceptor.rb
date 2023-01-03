# frozen_string_literal: true

require "sea_shanty/faraday/middleware"
require "sea_shanty/faraday/rack_builder"

module SeaShanty
  module Faraday
    class Interceptor
      def intercept!(request_store)
        Middleware.request_store = request_store
        ::Faraday::ConnectionOptions.memoized(:builder_class) { RackBuilder }
      end
    end
  end
end
