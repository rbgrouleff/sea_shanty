# frozen_string_literal: true

require "pathname"

module SeaShanty
  class RequestStore
    def initialize(storage_dir)
      @storage_dir = Pathname.new(storage_dir)
    end

    def has_response_for?(request)
      storage_dir.join(relative_stored_request_path(request)).exist?
    end

    def store(request, response)
      file_path = storage_dir.join(relative_stored_request_path(request))
      file_path.dirname.mkpath
      file_path.open("w+") do |file|
        file.write("")
      end
    end

    private

    attr_reader :storage_dir

    def relative_stored_request_path(request)
      filename = "#{request.digest}.yml"
      Pathname.new(request.url.hostname).join(request.url.path.delete_prefix("/"), request.method.to_s, filename)
    end
  end
end
