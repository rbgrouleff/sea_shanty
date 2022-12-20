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

    def test_it_contains_a_stored_request
      request = Request.new(method: :get, url: URI::parse("https://example.com/hello"), headers: {}, body: "request body")
      response = Response.new(status: 200, message: :ok, headers: {}, body: "response body")
      @request_store.store(request, response)
      assert(@request_store.has_response_for?(request))
    end
  end
end
