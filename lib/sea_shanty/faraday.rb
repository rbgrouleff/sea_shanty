# frozen_string_literal: true

require "sea_shanty/faraday/interceptor"

SeaShanty.register_interceptor(:faraday, SeaShanty::Faraday::Interceptor.new)
