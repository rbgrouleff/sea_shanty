# frozen_string_literal: true

require "pathname"

module SeaShanty
  class RequestStore
    def initialize(storage_dir)
      @storage_dir = Pathname.new(storage_dir)
    end

    def has_response_for?(request)
      storage_dir.join(request.file_path).exist?
    end

    def store(request, response)
      file_path = storage_dir.join(request.file_path)
      file_path.dirname.mkpath
      file_path.open("w+") do |file|
        file.write("")
      end
    end

    private

    attr_reader :storage_dir
  end
end
