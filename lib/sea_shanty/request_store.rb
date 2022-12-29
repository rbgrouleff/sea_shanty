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
      elsif configuration.readonly?
        load_response(request)
      elsif has_response_for?(request)
        load_response(request)
      else
        response = yield
        store(request, response) unless configuration.bypass?
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

    attr_reader :configuration, :generic_responses, :storage_dir, :request_serializer

    def request_file_path(request)
      _, generic_file_path = generic_responses.find { |matcher, path| matcher.match?(request.url.to_s) }
      file_path = if generic_file_path.nil?
        request_serializer.file_path(request)
      else
        Pathname.new(generic_file_path.to_s)
      end

      storage_dir.join(file_path)
    end

    def serialize(request, response)
      {
        request: request_serializer.serialize(request),
        response: response.to_h,
        stored_at: DateTime.now.to_s
      }
    end
  end
end
