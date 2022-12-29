# frozen_string_literal: true

require "sea_shanty/errors"

module SeaShanty
  class Configuration
    attr_accessor :bypass, :readonly, :storage_dir
    attr_reader :request_body_filter, :request_headers_filter
    alias_method :bypass?, :bypass
    alias_method :readonly?, :readonly

    def generic_responses=(responses)
      unless Hash === responses
        raise(
          ConfigurationError,
          "Generic responses must be a hash that maps a Regexp or something else that responds to `match?` to a relative path to a file with a recorded response."
        )
      end

      raise ConfigurationError, "keys in the generic responses hash must respond to `match?`." unless responses.keys.all? { |key| key.respond_to?(:match?) }

      @generic_responses = responses
    end

    def generic_responses
      @generic_responses ||= {}
    end

    def request_body_filter=(filter)
      raise ConfigurationError, "Filter must have a call method" unless filter.respond_to?(:call)
      raise ConfigurationError, "Filter must have an arity of exactly 1" unless filter.arity == 1
      @request_body_filter = filter
    end

    def request_headers_filter=(filter)
      raise ConfigurationError, "Filter must have a call method" unless filter.respond_to?(:call)
      raise ConfigurationError, "Filter must have an arity of exactly 2" unless filter.arity == 2
      @request_headers_filter = filter
    end
  end
end
