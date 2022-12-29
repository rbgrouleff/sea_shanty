# frozen_string_literal: true

require "sea_shanty/errors"
require "sea_shanty/configuration"
require "sea_shanty/faraday"
require "sea_shanty/version"

module SeaShanty
  TRUE_VALUES = %w[1 yes y true]

  module_function

  def configuration
    @configuration ||= Configuration.new
  end

  def configure(&block)
    yield configuration

    configuration.bypass = configuration_overwrite(ENV["SEA_SHANTY_BYPASS"], configuration.bypass)
    configuration.readonly = configuration_overwrite(ENV["SEA_SHANTY_READONLY"], configuration.readonly)
  end

  def intercept(identifier)
    intercepted_libraries << identifier unless intercepted_libraries.include?(identifier)
  end

  def intercepted_libraries
    @intercepted_libraries ||= []
  end

  def configuration_overwrite(env_var, value)
    if env_var.nil? || env_var.empty?
      value
    else
      TRUE_VALUES.include?(env_var.downcase)
    end
  end
end
