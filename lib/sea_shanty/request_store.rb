# frozen_string_literal: true

require "date"
require "pathname"
require "yaml"
require "sea_shanty/request_serializer"

module SeaShanty
  class RequestStore
    def initialize(configuration, generic_responses: configuration.generic_responses, storage_dir: configuration.storage_dir)
      @configuration = configuration
      @generic_responses = generic_responses
      @storage_dir = Pathname.new(storage_dir)
      @request_serializer = RequestSerializer.new(headers_filter: configuration.request_headers_filter, body_filter: configuration.request_body_filter)
    end

    def fetch(request, &block)
      if configuration.bypass?
        raise ConfigurationError, "Bypass and readonly are both true - please set only one of them." if configuration.readonly?
        yield
      else
        path = request_file_path(request)
        if configuration.readonly? || path.exist?
          load_response(path, request)
        else
          response = yield
          store(path, request, response) unless configuration.bypass?
          response
        end
      end
    end

    def load_response(path, request)
      raise UnknownRequest, "SeaShanty: Unknown request #{request.method.to_s.upcase} to #{request.url}" unless path.exist?
      log("Loading response for #{request.url} from #{path}")
      contents = YAML.safe_load(Pathname(path).read, permitted_classes: [Symbol, Time, DateTime])
      Response.from_h(contents.fetch(:response))
    end

    def store(path, request, response)
      log("Storing response for #{request.url} in #{path}")
      path.dirname.mkpath
      path.open("w+") do |file|
        file.write(YAML.dump(serialize(request, response)))
      end
    end

    def request_file_path(request)
      _, generic_file_path = generic_responses.find { |matcher, path| matcher.match?(request.url.to_s) }
      file_path = if generic_file_path.nil?
        request_serializer.file_path(request).tap { |path| log("Generated #{path} for request to #{request.url}") }
      else
        log("Found a generic response in #{generic_file_path} for request to #{request.url}")
        Pathname.new(generic_file_path.to_s)
      end

      storage_dir.join(file_path)
    end

    private

    attr_reader :configuration, :generic_responses, :storage_dir, :request_serializer

    def serialize(request, response)
      {
        request: request_serializer.serialize(request),
        response: response.to_h,
        stored_at: DateTime.now.to_s
      }
    end

    def log(message)
      configuration.logger.log(message)
    end
  end
end
