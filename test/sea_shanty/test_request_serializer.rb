# frozen_string_literal: true

require "test_helper"
require "uri"
require "sea_shanty/request_serializer"
require "sea_shanty/request"

module SeaShanty
  class TestRequestSerializer < Minitest::Test
    def setup
      @method = :get
      @url = URI.parse("https://example.com/hello")
      @headers = {"Authorization" => "auth-header", "Accept" => "application/json"}
      @body = "body - value:32890"
      @request = Request.new(method: @method, url: @url, headers: @headers, body: @body)
    end

    def test_serialize_serializes_a_request
      serializer = RequestSerializer.new
      expected = @request.to_h

      assert_equal(expected, serializer.serialize(@request))
    end

    def test_serialize_duplicates_the_headers_hash
      serializer = RequestSerializer.new
      expected = @request.to_h.fetch(:headers)

      refute_same(expected, serializer.serialize(@request).fetch(:headers))
    end

    def test_serialize_filters_the_headers
      header_name = "Authorization"
      replacement = "<auth token>"
      serializer = RequestSerializer.new(headers_filter: lambda { |name, value| (name == header_name) ? replacement : value })

      assert_equal(replacement, serializer.serialize(@request).dig(:headers, header_name))
    end

    def test_serialize_does_not_touch_headers_that_do_not_match_the_filter
      filtered_header_name = "Authorization"
      unfiltered_header_name = "Accept"
      serializer = RequestSerializer.new(headers_filter: lambda { |name, value| (name == filtered_header_name) ? value.reverse : value })

      assert_equal(@headers.fetch(unfiltered_header_name), serializer.serialize(@request).dig(:headers, unfiltered_header_name))
    end

    def test_serialize_filters_all_headers_matching_the_headers_filter
      replacement = "value was replaced"
      serializer = RequestSerializer.new(headers_filter: lambda { |_name, _value| replacement })

      assert_operator(serializer.serialize(@request).fetch(:headers).values, :all?, lambda { |value| value == replacement })
    end

    def test_serialize_uses_filtered_body
      filtered_body = "filtered"
      serializer = RequestSerializer.new(body_filter: lambda { |body| filtered_body })

      assert_equal(filtered_body, serializer.serialize(@request).fetch(:body))
    end

    def test_digest_uses_http_method_url_and_body
      expected_digest = Digest::SHA1.hexdigest(@method.to_s + @url.to_s + @body)
      serializer = RequestSerializer.new
      assert_equal(expected_digest, serializer.digest(@request))
    end

    def test_filename
      serializer = RequestSerializer.new
      assert_equal("#{serializer.digest(@request)}.yml", serializer.filename(@request))
    end

    def test_file_path
      serializer = RequestSerializer.new
      expected = Pathname
        .new(@url.hostname)
        .join(@url.path.delete_prefix("/").split("/").join(File::SEPARATOR), @method.to_s, serializer.filename(@request))
      assert_equal(expected, serializer.file_path(@request))
    end

    def test_digest_applies_body_filter_before_calculating_digest
      altered_body = "altered body"
      expected_digest = Digest::SHA1.hexdigest(@method.to_s + @url.to_s + altered_body)
      serializer = RequestSerializer.new(body_filter: lambda { |b| altered_body })
      assert_equal(expected_digest, serializer.digest(@request))
    end

    def test_filename_applies_body_filter
      serializer = RequestSerializer.new(body_filter: lambda { |b| "altered body" })
      assert_equal("#{serializer.digest(@request)}.yml", serializer.filename(@request))
    end

    def test_file_path_applies_body_filter
      serializer = RequestSerializer.new(body_filter: lambda { |b| "altered body" })
      expected = Pathname
        .new(@url.hostname)
        .join(@url.path.delete_prefix("/").split("/").join(File::SEPARATOR), @method.to_s, serializer.filename(@request))
      assert_equal(expected, serializer.file_path(@request))
    end
  end
end
