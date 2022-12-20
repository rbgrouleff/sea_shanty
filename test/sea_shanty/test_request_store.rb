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
      @request_store = RequestStore.new(Pathname.new(@dir))
      @request = Request.new(method: :get, url: URI::parse("https://example.com/hello"), headers: {}, body: "request body")
      @response = Response.new(status: 200, message: :ok, headers: {}, body: "response body")
    end

    def teardown
      FileUtils.remove_entry(@dir)
    end

    def test_it_stores_a_request_with_the_resulting_response
      stored_request_file_path = Pathname(@dir).join(@request.file_path)
      @request_store.store(@request, @response)
      assert_path_exists(stored_request_file_path)
    end

    def test_the_stored_request_includes_the_response
      stored_request_file_path = Pathname(@dir).join(@request.file_path)
      @request_store.store(@request, @response)
      serialized_file_content = YAML.load(stored_request_file_path.read)
      assert(serialized_file_content.has_key?(:response))
      assert_equal(@response.to_h, serialized_file_content.fetch(:response))
    end

    def test_the_stored_request_includes_the_request
      stored_request_file_path = Pathname(@dir).join(@request.file_path)
      @request_store.store(@request, @response)
      serialized_file_content = YAML.load(stored_request_file_path.read)
      assert(serialized_file_content.has_key?(:request))
      assert_equal(@request.to_h, serialized_file_content.fetch(:request))
    end

    def test_the_stored_request_includes_the_time_of_saving
      stored_request_file_path = Pathname(@dir).join(@request.file_path)
      @request_store.store(@request, @response)
      expected = DateTime.parse(DateTime.now.to_s)
      serialized_file_content = YAML.load(stored_request_file_path.read)
      assert(serialized_file_content.has_key?(:stored_at))
      assert_equal(expected, DateTime.parse(serialized_file_content.fetch(:stored_at)))
    end

    def test_it_has_the_reponse_for_a_stored_request
      @request_store.store(@request, @response)
      assert(@request_store.has_response_for?(@request))
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
  end
end
