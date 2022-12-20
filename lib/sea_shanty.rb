# frozen_string_literal: true

require "sea_shanty/errors"
require "sea_shanty/configuration"
require "sea_shanty/version"

module SeaShanty
  module_function

  def configuration
    @configuration ||= Configuration.new
  end

  def configure(&block)
    yield configuration
  end
end
