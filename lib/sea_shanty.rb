# frozen_string_literal: true

require "sea_shanty/errors"
require "sea_shanty/configuration"
require "sea_shanty/request_store"
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
    return if intercepting.include?(identifier)
    interceptors.fetch(identifier).intercept!(request_store)
    intercepting << identifier
  rescue KeyError
    raise(
      UnknownInterceptor,
      "Cannot find an interceptor for #{identifier}. Available interceptors are: [#{interceptors.keys.join(", ")}]"
    )
  end

  def intercepting
    @intercepting ||= []
  end

  def interceptors
    @interceptors ||= {}
  end

  def register_interceptor(identifier, interceptor)
    interceptors[identifier] = interceptor
  end

  def remove(identifier)
    return unless intercepting.include?(identifier)
    interceptors.fetch(identifier).remove
    intercepting.delete(identifier)
  rescue KeyError
    raise(
      UnknownInterceptor,
      "Cannot find an interceptor for #{identifier}. Available interceptors are: [#{interceptors.keys.join(", ")}]"
    )
  end

  def request_store
    RequestStore.new(configuration)
  end

  def reset!
    @configuration = Configuration.new
    configure {  }
  end

  def configuration_overwrite(env_var, value)
    if env_var.nil? || env_var.empty?
      value
    else
      TRUE_VALUES.include?(env_var.downcase)
    end
  end
end
