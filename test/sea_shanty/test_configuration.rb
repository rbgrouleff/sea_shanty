# frozen_string_literal: true

require "test_helper"

module SeaShanty
  class TestConfiguration < Minitest::Test
    def setup
      @configuration = Configuration.new
    end

    def test_it_has_a_generic_responses_reader
      assert_respond_to(@configuration, :generic_responses)
    end

    def test_it_has_a_generic_responses_writer
      assert_respond_to(@configuration, :generic_responses=)
    end

    def test_setting_generic_responses_to_something_else_than_a_hash
      assert_raises(ConfigurationError) { @configuration.generic_responses = :foo }
    end

    def test_setting_generic_responses_to_a_hash_with_key_that_does_not_respond_to_match_predicate
      assert_raises(ConfigurationError) { @configuration.generic_responses = {1 => :foo} }
    end

    def test_generic_responses_is_memoized
      assert_same(@configuration.generic_responses, @configuration.generic_responses)
    end
  end
end
