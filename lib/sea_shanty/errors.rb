# frozen_string_literal: true

module SeaShanty
  class Error < StandardError
  end

  class ConfigurationError < Error
  end

  class UnknownRequest < Error
  end

  class UnknownInterceptor < Error
  end
end
