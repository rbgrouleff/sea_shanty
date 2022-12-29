# frozen_string_literal: true

require "digest/sha1"
require "pathname"

module SeaShanty
  class RequestSerializer
    def initialize(headers_filter: lambda { |_name, value| value }, body_filter: lambda { |body| body })
      @headers_filter = headers_filter
      @body_filter = body_filter
    end

    def digest(request)
      Digest::SHA1.hexdigest(request.method.to_s + request.url.to_s + body_filter.call(request.body.to_s))
    end

    def filename(request)
      "#{digest(request)}.yml"
    end

    def file_path(request)
      # Don't assume system directory separator is /
      url_path = request.url.path.delete_prefix("/").split("/").join(File::SEPARATOR)
      Pathname.new(request.url.hostname).join(url_path, request.method.to_s, filename(request))
    end

    def serialize(request)
      hash = request.to_h
      hash[:headers] = hash.fetch(:headers).map { |name, value| [name, headers_filter.call(name, value)] }.to_h
      hash[:body] = body_filter.call(hash.fetch(:body))
      hash
    end

    private

    attr_reader :headers_filter, :body_filter
  end
end
