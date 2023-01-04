# frozen_string_literal: true

require "test_helper"
require "fileutils"
require "sea_shanty"

class TestSeaShanty < Minitest::Test
  def setup
    SeaShanty.configure do |config|
      config.storage_dir = Dir.mktmpdir("sea_shanty")
    end
  end

  def teardown
    FileUtils.remove_entry(SeaShanty.configuration.storage_dir)
  end

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

  def test_configure_overwrites_bypass_with_env_variable
    ENV["SEA_SHANTY_BYPASS"] = "1"
    SeaShanty.configure do |config|
      config.bypass = false
    end

    assert_predicate(SeaShanty.configuration, :bypass?)
  end

  def test_configure_overwrites_bypass_with_false_if_env_var_is_not_true
    ENV["SEA_SHANTY_BYPASS"] = "F"
    SeaShanty.configure do |config|
      config.bypass = true
    end

    refute_predicate(SeaShanty.configuration, :bypass?)
  end

  def test_configure_overwrites_readonly_with_env_variable
    ENV["SEA_SHANTY_READONLY"] = "1"
    SeaShanty.configure do |config|
      config.readonly = false
    end

    assert_predicate(SeaShanty.configuration, :readonly?)
  end

  def test_configure_overwrites_readonly_with_false_if_env_var_is_not_true
    ENV["SEA_SHANTY_READONLY"] = "F"
    SeaShanty.configure do |config|
      config.readonly = true
    end

    refute_predicate(SeaShanty.configuration, :readonly?)
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
