# frozen_string_literal: true

require "date"
require "pathname"
require "yaml"

module SeaShanty
  class RequestStore
    def initialize(configuration, generic_responses: configuration.generic_responses, storage_dir: configuration.storage_dir)
      @configuration = configuration
      @generic_responses = generic_responses
      @storage_dir = Pathname.new(storage_dir)
    end

    def fetch(request, &block)
      if has_response_for?(request)
        load_response(request)
      else
        response = yield
        store(request, response)
        response
      end
    end

    def has_response_for?(request)
      request_file_path(request).exist?
    end

    def load_response(request)
      raise UnknownRequest, "SeaShanty: Unknown request #{request.method.to_s.upcase} to #{request.url}" unless has_response_for?(request)
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

    attr_reader :configuration, :generic_responses, :storage_dir

    def request_file_path(request)
      _, generic_file_path = generic_responses.find { |matcher, path| matcher.match?(request.url.to_s) }
      file_path = if generic_file_path.nil?
        request.file_path
      else
        generic_file_path.to_s.delete_prefix("/")
      end

      storage_dir.join(file_path)
    end

    def serialize(request, response)
      {
        request: request.serialize,
        response: response.serialize,
        stored_at: DateTime.now.to_s
      }
    end
  end
end
