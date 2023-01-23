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
    SeaShanty.interceptors.keys.each do |name|
      SeaShanty.remove(name)
    end

    FileUtils.remove_entry(SeaShanty.configuration.storage_dir)
    ENV.delete("SEA_SHANTY_BYPASS")
    ENV.delete("SEA_SHANTY_READONLY")
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

  def test_register_interceptor_registers_an_interecptor_class
    interceptor_class = Class.new
    SeaShanty.register_interceptor(:name, interceptor_class)
    assert_includes(SeaShanty.interceptors.values, interceptor_class)
  end

  def test_intercept_with_an_unknown_interceptor_name
    assert_raises(SeaShanty::UnknownInterceptor) { SeaShanty.intercept(:nope) }
  end

  def test_intercept_calls_the_interceptor
    identifier = :test
    interceptor = interceptor_dummy.new
    SeaShanty.register_interceptor(identifier, interceptor)
    SeaShanty.intercept(identifier)
    assert_predicate(interceptor, :intercepted)
  end

  def test_intercept_only_calls_the_interceptor_once
    interceptor = interceptor_dummy.new
    identifier = :foo
    SeaShanty.register_interceptor(identifier, interceptor)
    SeaShanty.intercept(identifier)
    SeaShanty.intercept(identifier)
    assert_equal(1, interceptor.intercept_count)
  end

  def test_remove_removes_an_interceptor
    interceptor = interceptor_dummy.new
    identifier = :foo
    SeaShanty.register_interceptor(identifier, interceptor)
    SeaShanty.intercept(identifier)
    SeaShanty.remove(identifier)
    assert_predicate(interceptor, :removed)
  end

  def test_remove_does_not_remove_an_interceptor_that_does_not_intercept
    interceptor = interceptor_dummy.new
    identifier = :foo
    SeaShanty.register_interceptor(identifier, interceptor)
    SeaShanty.remove(identifier)
    refute_predicate(interceptor, :removed)
  end

  def test_remove_does_not_prevent_an_interceptor_from_intercepting_again
    interceptor = interceptor_dummy.new
    identifier = :foo
    SeaShanty.register_interceptor(identifier, interceptor)
    SeaShanty.intercept(identifier)
    SeaShanty.remove(identifier)
    SeaShanty.intercept(identifier)
    assert_equal(2, interceptor.intercept_count)
  end

  def test_request_store_returns_a_request_store_instance
    assert_kind_of(SeaShanty::RequestStore, SeaShanty.request_store)
  end

  def test_that_it_has_a_version_number
    refute_nil ::SeaShanty::VERSION
  end

  private

  def interceptor_dummy
    Class.new do
      attr_reader(:intercepted, :intercept_count, :removed)

      def initialize
        @intercept_count = 0
        @intercepted = false
        @removed = false
      end

      def intercept!(request_store)
        @intercepted = true
        @intercept_count += 1
      end

      def remove
        @removed = true
      end
    end
  end
end
