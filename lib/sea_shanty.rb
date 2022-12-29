# frozen_string_literal: true

require "sea_shanty/errors"
require "sea_shanty/configuration"
require "sea_shanty/version"

module SeaShanty
  TRUE_VALUES = %w[1 yes y true]

  module_function

  def configuration
    @configuration ||= Configuration.new
  end

  def configure(&block)
    yield configuration
    if ENV["SEA_SHANTY_BYPASS"].present?
      configuration.bypass = TRUE_VALUES.include?(ENV["SEA_SHANTY_BYPASS"].downcase)
    end

    if ENV["SEA_SHANTY_READONLY"].present?
      configuration.readonly = TRUE_VALUES.include?(ENV["SEA_SHANTY_READONLY"].downcase)
    end
  end
end
