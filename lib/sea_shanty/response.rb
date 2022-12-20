# frozen_literal_string: true

module SeaShanty
  class Response
    attr_reader :body, :headers, :message, :status

    def initialize(status:, message:, headers:, body:)
      @status = status
      @message = message
      @headers = headers
      @body = body
    end

    def to_h
      {
        status: {
          code: status.to_i,
          message: message
        },
        headers: headers,
        body: {
          string: body.to_s,
          encoding: body.nil? ? "" : body.encoding.name
        }
      }
    end
  end
end
