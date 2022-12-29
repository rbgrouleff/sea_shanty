# frozen_string_literal: true

module SeaShanty
  class Request
    attr_reader :method, :url, :headers, :body

    def initialize(method:, url:, headers:, body:)
      @method = method
      @url = url
      @headers = headers
      @body = body
    end

    def to_h
      {
        method: method.to_s,
        url: url.to_s,
        headers: headers,
        body: {
          string: body.to_s,
          encoding: body.nil? ? "" : body.encoding.name
        }
      }
    end
  end
end
