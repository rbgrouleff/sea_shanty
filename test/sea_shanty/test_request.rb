# string_literal_frozen: true

require "test_helper"
require "uri"
require "sea_shanty/request"

module SeaShanty
  class TestRequest < Minitest::Test
    def setup
      @request = Request.new(method: nil, url: nil, headers: nil, body: nil)
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

    def test_digest_uses_http_method_url_and_body
      method = :get
      url = URI::parse("https://example.com/hello")
      headers = {}
      body = "body"
      request = Request.new(method: method, url: url, headers: headers, body: body)

      expected_digest = Digest::SHA1.hexdigest(method.to_s + url.to_s + body)
      assert_equal(expected_digest, request.digest)
    end
  end
end
