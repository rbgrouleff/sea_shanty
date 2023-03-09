# frozen_string_literal: true

module SeaShanty
  class Logger
    attr_reader :destination

    def initialize(destination)
      @destination = if destination.respond_to? :printf
        destination
      else
        File.open(destination.to_s, "a+")
      end
    end

    def log(message)
      destination.write(message)
      destination.write("\n") unless message.end_with?("\n")
    end
  end
end
