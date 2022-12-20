# string_literal_frozen: true

require "digest/sha1"
require "pathname"

module SeaShanty
  class Request
    attr_reader :method, :url, :headers, :body

    def initialize(method:, url:, headers:, body:)
      @method = method
      @url = url
      @headers = headers
      @body = body
    end

    def digest
      Digest::SHA1.hexdigest(method.to_s + url.to_s + body.to_s)
    end

    def filename
      "#{digest}.yml"
    end

    def file_path
      # Don't assume system directory separator is /
      url_path = url.path.delete_prefix("/").split("/").join(File::SEPARATOR)
      Pathname.new(url.hostname).join(url_path, method.to_s, filename)
    end
  end
end
