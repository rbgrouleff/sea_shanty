# frozen_string_literal: true

require "date"
require "pathname"
require "yaml"

module SeaShanty
  class RequestStore
    def initialize(storage_dir)
      @storage_dir = Pathname.new(storage_dir)
    end

    def has_response_for?(request)
      request_file_path(request).exist?
    end

    def load_response(request)
      raise UnknownRequest, "SeaShanty: Unknown request #{request.method.to_s.upcase} to #{request.url.to_s}" unless has_response_for?(request)
      contents = YAML.load(request_file_path(request).read)
      Response.from_h(contents.fetch(:response))
    end

    def store(request, response)
      file_path = request_file_path(request)
      file_path.dirname.mkpath
      file_path.open("w+") do |file|
        file.write(YAML.dump(serialize(request, response)))
      end
    end

    private

    attr_reader :storage_dir

    def request_file_path(request)
      storage_dir.join(request.file_path)
    end

    def serialize(request, response)
      {
        request: request.to_h,
        response: response.to_h,
        stored_at: DateTime.now.to_s
      }
    end
  end
end
