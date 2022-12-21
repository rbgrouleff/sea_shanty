module SeaShanty
  class Error < StandardError
  end

  class ConfigurationError < Error
  end

  class UnknownRequest < Error
  end
end
