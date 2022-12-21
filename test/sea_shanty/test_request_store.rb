# frozen_string_literal: true

require "test_helper"
require "fileutils"
require "pathname"
require "uri"
require "sea_shanty/request"
require "sea_shanty/response"
require "sea_shanty/request_store"

module SeaShanty
  class TestRequestStore < Minitest::Test
    def setup
      @dir = Dir.mktmpdir("sea_shanty")
      @config = Configuration.new
      @request_store = RequestStore.new(@config, storage_dir: Pathname.new(@dir))
      @request = Request.new(method: :get, url: URI.parse("https://example.com/hello"), headers: {}, body: "request body")
      @response = Response.new(status: 200, message: :ok, headers: {}, body: "response body")
    end

    def teardown
      FileUtils.remove_entry(@dir)
    end

    def test_it_stores_a_request_with_the_resulting_response
      @request_store.store(@request, @response)
      assert_path_exists(path_for_request(@request))
    end

    def test_the_stored_request_includes_the_response
      @request_store.store(@request, @response)
      serialized_file_content = YAML.load(path_for_request(@request).read)
      assert(serialized_file_content.has_key?(:response))
      assert_equal(@response.to_h, serialized_file_content.fetch(:response))
    end

    def test_the_stored_request_includes_the_request
      @request_store.store(@request, @response)
      serialized_file_content = YAML.load(path_for_request(@request).read)
      assert(serialized_file_content.has_key?(:request))
      assert_equal(@request.to_h, serialized_file_content.fetch(:request))
    end

    def test_the_stored_request_includes_the_time_of_saving
      @request_store.store(@request, @response)
      expected = DateTime.parse(DateTime.now.to_s)
      serialized_file_content = YAML.load(path_for_request(@request).read)
      assert(serialized_file_content.has_key?(:stored_at))
      assert_equal(expected, DateTime.parse(serialized_file_content.fetch(:stored_at)))
    end

    def test_it_has_the_reponse_for_a_stored_request
      @request_store.store(@request, @response)
      assert(@request_store.has_response_for?(@request))
    end

    def test_it_has_the_response_when_a_generic_response_regex_matches_request_url
      generic_request = Request.new(method: :get, url: URI.parse("https://example.com/generic/1234"), headers: {}, body: nil)
      generic_response = Response.new(status: 200, message: "OK", headers: {}, body: "generic response")
      @request_store.store(generic_request, generic_response)
      @config.generic_responses[/\/generic\//] = generic_request.file_path
      actual_request = Request.new(method: :get, url: URI.parse("https://example.com/generic/actual"), headers: {}, body: nil)
      actual_response = @request_store.fetch(actual_request) do
        raise "NOPE"
      end

      assert_equal(generic_response, actual_response)
    end

    def test_it_passes_to_blocck_when_generic_response_regex_does_not_match_request_url
      generic_request = Request.new(method: :get, url: URI.parse("https://example.com/generic/1234"), headers: {}, body: nil)
      generic_response = Response.new(status: 200, message: "OK", headers: {}, body: "generic response")
      @request_store.store(generic_request, generic_response)
      @config.generic_responses[/\/generic\//] = generic_request.file_path
      actual_request = Request.new(method: :get, url: URI.parse("https://example.com/not_generic/actual"), headers: {}, body: nil)
      expected_response = Response.new(status: 200, message: "OK", headers: {}, body: "NOT generic response")
      actual_response = @request_store.fetch(actual_request) do
        expected_response
      end

      assert_equal(expected_response, actual_response)
    end

    def test_load_response_finds_the_response_for_a_stored_request
      @request_store.store(@request, @response)
      assert_equal(@response, @request_store.load_response(@request))
    end

    def test_load_response_raises_if_request_is_unknown
      method = :put
      refute_equal(method, @request.method)
      request = Request.new(method: method, url: @request.url, headers: @request.headers, body: @request.body)
      assert_raises(UnknownRequest) { @request_store.load_response(request) }
    end

    def test_fetch_returns_stored_response
      @request_store.store(@request, @response)
      returned_response = @request_store.fetch(@request) do
        raise "NOPE"
      end

      assert_equal(@response, returned_response)
    end

    def test_fetch_stores_response_for_unknown_request
      refute(@request_store.has_response_for?(@request))
      @request_store.fetch(@request) do
        @response
      end

      assert(@request_store.has_response_for?(@request))
    end

    def test_fetch_returns_stored_response_after_storing_it
      returned_response = @request_store.fetch(@request) do
        @response
      end

      assert_equal(@response, returned_response)
    end

    def path_for_request(request)
      Pathname(@dir).join(request.file_path)
    end
  end
end
