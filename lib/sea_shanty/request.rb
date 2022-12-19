# string_literal_frozen: true

require "digest/sha1"

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
  end
end
