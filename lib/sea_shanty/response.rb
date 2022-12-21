# frozen_literal_string: true

module SeaShanty
  class Response
    attr_reader :body, :headers, :message, :status, :original_response

    class << self
      def from_h(hash)
        new(
          status: hash.fetch(:status).fetch(:code),
          message: hash.fetch(:status).fetch(:message),
          headers: hash.fetch(:headers),
          body: hash.fetch(:body).fetch(:encoding).empty? ? nil : hash.fetch(:body).fetch(:string)
        )
      end
    end

    def initialize(status:, message:, headers:, body:, original_response: ORIGINAL_RESPONSE_NOT_PRESENT)
      @status = Integer(status, status.is_a?(String) ? 10 : 0)
      @message = message
      @headers = headers
      @body = body
      @original_response = original_response
    end

    def to_h
      {
        status: {
          code: status,
          message: message
        },
        headers: headers,
        body: {
          string: body.to_s,
          encoding: body.nil? ? "" : body.encoding.name
        }
      }
    end

    def was_stored?
      ORIGINAL_RESPONSE_NOT_PRESENT != original_response
    end

    def ==(other)
      self.class === other &&
        status == other.status && message == other.message && headers == other.headers &&
        body == other.body
    end

    alias_method :eql?, :==

    def hash
      self.class.hash ^ status.hash ^ message.hash ^ headers.hash ^ body.hash
    end

    private

    ORIGINAL_RESPONSE_NOT_PRESENT = :original_response_not_present
  end
end
