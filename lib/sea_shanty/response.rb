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
  end
end
