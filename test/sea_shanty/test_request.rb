# frozen_string_literal: true

require "test_helper"
require "uri"
require "sea_shanty/request"
require "sea_shanty/request_serializer"

module SeaShanty
  class TestRequest < Minitest::Test
    def setup
      @method = :get
      @url = URI.parse("https://example.com/hello")
      @headers = {}
      @body = "body"
      @request = Request.new(method: @method, url: @url, headers: @headers, body: @body)
    end

    def test_has_a_method
      assert_respond_to(@request, :method)
    end

    def test_has_an_url
      assert_respond_to(@request, :url)
    end

    def test_has_a_headers
      assert_respond_to(@request, :headers)
    end

    def test_has_a_body
      assert_respond_to(@request, :body)
    end

    def test_to_h_encodes_request_as_a_hash
      expected = {
        method: @method.to_s,
        url: @url.to_s,
        headers: @headers,
        body: {
          string: @body.to_s,
          encoding: @body.encoding.name
        }
      }
      assert_equal(expected, @request.to_h)
    end

    def test_to_h_handles_nil_body
      request = Request.new(method: @method, url: @url, headers: @headers, body: nil)
      expected = {
        method: @method.to_s,
        url: @url.to_s,
        headers: @headers,
        body: {
          string: "",
          encoding: ""
        }
      }
      assert_equal(expected, request.to_h)
    end

    def test_url_can_be_a_string
      serializer = RequestSerializer.new
      request = Request.new(method: @method, url: @url.to_s, headers: @headers, body: @body)
      assert(serializer.file_path(request))
    end
  end
end
