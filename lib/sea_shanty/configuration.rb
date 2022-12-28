# frozen_string_literal: true

require "sea_shanty/errors"

module SeaShanty
  class Configuration
    attr_accessor :bypass, :readonly
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
  end
end
