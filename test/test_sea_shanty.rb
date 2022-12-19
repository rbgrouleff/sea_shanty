# frozen_string_literal: true

require "test_helper"

class TestSeaShanty < Minitest::Test
  def test_it_has_a_configuration
    assert_kind_of(SeaShanty::Configuration, SeaShanty.configuration)
  end

  def test_configuration_is_a_singleton
    assert_equal(SeaShanty.configuration.object_id, SeaShanty.configuration.object_id)
  end

  def test_configure_yields_the_configuration
    yielded_object = nil
    SeaShanty.configure do |config|
      yielded_object = config
    end

    assert_equal(SeaShanty.configuration.object_id, yielded_object.object_id)
  end

  def test_that_it_has_a_version_number
    refute_nil ::SeaShanty::VERSION
  end
end
