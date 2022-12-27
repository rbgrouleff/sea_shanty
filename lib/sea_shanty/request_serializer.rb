# frozen_string_literal: true

module SeaShanty
  class RequestSerializer
    def initialize(headers_filter: lambda { |_name, value| value }, body_filter: lambda { |body| body })
      @headers_filter = headers_filter
      @body_filter = body_filter
    end

    def serialize(request)
      hash = Hash[request.to_h]
      hash[:headers] = Hash[hash.fetch(:headers).map { |name, value| [name, headers_filter.(name, value)] }]
      hash[:body] = body_filter.(hash.fetch(:body))
      hash
    end

    private

    attr_reader :headers_filter, :body_filter
  end
end
