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

    def test_it_has_a_storage_dir_reader
      assert_respond_to(@configuration, :storage_dir)
    end

    def test_it_has_a_storage_dir_writer
      assert_respond_to(@configuration, :storage_dir=)
    end

    def test_it_has_a_readonly_reader
      assert_respond_to(@configuration, :readonly)
    end

    def test_it_has_a_readonly_predicate_method
      assert_respond_to(@configuration, :readonly?)
    end

    def test_it_has_a_readonly_writer
      assert_respond_to(@configuration, :readonly=)
    end

    def test_setting_readonly_updates_it
      refute_predicate(@configuration, :readonly?)
      @configuration.readonly = true
      assert_predicate(@configuration, :readonly?)
    end

    def test_it_has_a_bypass_writer
      assert_respond_to(@configuration, :bypass=)
    end

    def test_it_has_a_bypass_reader
      assert_respond_to(@configuration, :bypass)
    end

    def test_it_has_a_bypass_predicate
      assert_respond_to(@configuration, :bypass?)
    end

    def test_setting_bypass_updates_it
      refute_predicate(@configuration, :bypass?)
      @configuration.bypass = true
      assert_predicate(@configuration, :bypass?)
    end

    def test_it_has_a_request_body_filter_reader
      assert_respond_to(@configuration, :request_body_filter)
    end

    def test_it_has_a_request_body_filter_writer
      assert_respond_to(@configuration, :request_body_filter=)
    end

    def test_it_has_a_request_headers_filter_reader
      assert_respond_to(@configuration, :request_headers_filter)
    end

    def test_it_has_a_request_headers_filter_writer
      assert_respond_to(@configuration, :request_headers_filter=)
    end

    def test_setting_request_body_filter_to_a_lambda
      filter = lambda { |body| body }
      @configuration.request_body_filter = filter
      assert_equal(filter, @configuration.request_body_filter)
    end

    def test_setting_request_body_filter_to_a_lambda_with_an_arity_larger_than_one
      filter = lambda { |body, _| body }
      assert_raises(ConfigurationError) { @configuration.request_body_filter = filter }
    end

    def test_setting_request_body_filter_to_a_lambda_with_an_arity_of_zero
      filter = lambda { "foo" }
      assert_raises(ConfigurationError) { @configuration.request_body_filter = filter }
    end

    def test_setting_request_body_filter_to_something_that_is_not_callable
      filter = :foo
      assert_raises(ConfigurationError) { @configuration.request_body_filter = filter }
    end

    def test_setting_request_headers_filter_to_a_lambda
      filter = lambda { |key, value| value }
      @configuration.request_headers_filter = filter
      assert_equal(filter, @configuration.request_headers_filter)
    end

    def test_setting_request_headers_filter_to_a_lambda_with_an_less_than_two
      filter = lambda { |key| headers }
      assert_raises(ConfigurationError) { @configuration.request_headers_filter = filter }
    end

    def test_setting_request_headers_filter_to_a_lambda_with_an_arity_larger_than_two
      filter = lambda { |key| headers }
      assert_raises(ConfigurationError) { @configuration.request_headers_filter = filter }
    end

    def test_setting_request_headers_filter_to_something_that_is_not_callable
      filter = :foo
      assert_raises(ConfigurationError) { @configuration.request_headers_filter = filter }
    end
  end
end
