# frozen_literal_string: true

module SeaShanty
  class Response
    attr_reader :body, :headers, :message, :status, :original_response

    class << self
      def from_h(hash)
        new(
          status: hash.fetch(:status).fetch(:code).to_i,
          message: hash.fetch(:status).fetch(:message),
          headers: hash.fetch(:headers),
          body: hash.fetch(:body).fetch(:encoding).empty? ? nil : hash.fetch(:body).fetch(:string)
        )
      end
    end

    def initialize(status:, message:, headers:, body:, original_response: ORIGINAL_RESPONSE_NOT_PRESENT)
      @status = status
      @message = message
      @headers = headers
      @body = body
      @original_response = original_response
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

    def was_stored?
      ORIGINAL_RESPONSE_NOT_PRESENT != original_response
    end

    def ==(other)
      self.class === other &&
        status.to_i == other.status.to_i &&
        message == other.message &&
        headers == other.headers &&
        body == other.body
    end

    alias :eql? :==

    def hash
      self.class.hash ^ status.to_i.hash ^ message.hash ^ headers.hash ^ body.hash
    end

    private

    ORIGINAL_RESPONSE_NOT_PRESENT = :original_response_not_present
  end
end
