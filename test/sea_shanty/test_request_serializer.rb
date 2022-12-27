# frozen_string_literal: true

require "test_helper"
require "uri"
require "sea_shanty/request_serializer"
require "sea_shanty/request"

module SeaShanty
  class TestRequestSerializer < Minitest::Test
    def setup
      @method = :get
      @url = URI.parse("https:/example.com/hello")
      @headers = {"Authorization" => "auth-header", "Accept" => "application/json"}
      @body = "body - value:32890"
    end

    def test_serialize_serializes_a_request
      serializer = RequestSerializer.new
      request = Request.new(method: @method, url: @url, headers: @headers, body: @body)
      expected = request.to_h

      assert_equal(expected, serializer.serialize(request))
    end

    def test_serialize_duplicates_the_headers_hash
      serializer = RequestSerializer.new
      request = Request.new(method: @method, url: @url, headers: @headers, body: @body)
      expected = request.to_h.fetch(:headers)

      refute_same(expected, serializer.serialize(request).fetch(:headers))
    end

    def test_serialize_filters_the_headers
      header_name = "Authorization"
      replacement = "<auth token>"
      request = Request.new(method: @method, url: @url, headers: @headers, body: @body)
      serializer = RequestSerializer.new(headers_filter: lambda { |name, value| name == header_name ? replacement : value })

      assert_equal(replacement, serializer.serialize(request).dig(:headers, header_name))
    end

    def test_serialize_does_not_touch_headers_that_do_not_match_the_filter
      filtered_header_name = "Authorization"
      unfiltered_header_name = "Accept"
      request = Request.new(method: @method, url: @url, headers: @headers, body: @body)
      serializer = RequestSerializer.new(headers_filter: lambda { |name, value| name == filtered_header_name ? value.reverse : value })

      assert_equal(@headers.fetch(unfiltered_header_name), serializer.serialize(request).dig(:headers, unfiltered_header_name))
    end

    def test_serialize_filters_all_headers_matching_the_headers_filter
      replacement = "value was replaced"
      request = Request.new(method: @method, url: @url, headers: @headers, body: @body)
      serializer = RequestSerializer.new(headers_filter: lambda { |_name, _value| replacement })

      assert_operator(serializer.serialize(request).fetch(:headers).values, :all?, lambda { |value| value == replacement })
    end

    def test_serialize_uses_filtered_body
      filtered_body = "filtered"
      request = Request.new(method: @method, url: @url, headers: @headers, body: @body)
      serializer = RequestSerializer.new(body_filter: lambda { |body| filtered_body })

      assert_equal(filtered_body, serializer.serialize(request).fetch(:body))
    end
  end
end
