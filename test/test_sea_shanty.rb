# frozen_string_literal: true

require "test_helper"

class TestSeaShanty < Minitest::Test
  def test_it_has_a_configuration
    assert_kind_of(SeaShanty::Configuration, SeaShanty.configuration)
  end

  def test_configuration_is_a_singleton
    assert_same(SeaShanty.configuration, SeaShanty.configuration)
  end

  def test_configure_yields_the_configuration
    yielded_object = nil
    SeaShanty.configure do |config|
      yielded_object = config
    end

    assert_same(SeaShanty.configuration, yielded_object)
  end

  def test_intercept_inserts_identifier_in_list
    skip("Not implemented yet...")
    assert_predicate(SeaShanty.intercepted_libraries, :empty?)
    SeaShanty.intercept(:faraday)
    assert_includes(SeaShanty.intercepted_libraries, :faraday)
  end

  def test_intercept_only_adds_same_library_once
    skip("Not implemented yet...")
    identifier = :foo
    assert_predicate(SeaShanty.intercepted_libraries, :empty?)
    SeaShanty.intercept(identifier)
    SeaShanty.intercept(identifier)
    assert_equal(1, SeaShanty.intercepted_libraries.count { |i| i == identifier })
  end

  def test_that_it_has_a_version_number
    refute_nil ::SeaShanty::VERSION
  end
end
