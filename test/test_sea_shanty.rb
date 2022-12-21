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

  def test_inject_inserts_identifier_in_list
    SeaShanty.inject(:faraday)
    assert_includes(SeaShanty.injected_libraries, :faraday)
  end

  def test_inject_only_adds_same_library_once
    identifier = :foo
    SeaShanty.inject(identifier)
    SeaShanty.inject(identifier)
    assert_equal(1, SeaShanty.injected_libraries.select { |i| i == identifier }.length)
  end

  def test_that_it_has_a_version_number
    refute_nil ::SeaShanty::VERSION
  end
end
