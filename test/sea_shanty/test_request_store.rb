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
    end

    def teardown
      FileUtils.remove_entry(@dir)
    end

    def test_it_stores_a_request_with_the_resulting_response
      request = Request.new(method: :get, url: URI::parse("https://example.com/hello"), headers: {}, body: "request body")
      response = Response.new(status: 200, message: :ok, headers: {}, body: "response body")
      stored_request = Pathname(@dir)
        .join(request.url.hostname)
        .join(request.url.path.delete_prefix("/"), request.method.to_s, "#{request.digest}.yml")
      @request_store.store(request, response)
      assert_predicate(stored_request, :exist?)
    end

    def test_it_contains_a_stored_request
      request = Request.new(method: :get, url: URI::parse("https://example.com/hello"), headers: {}, body: "request body")
      response = Response.new(status: 200, message: :ok, headers: {}, body: "response body")
      @request_store.store(request, response)
      assert(@request_store.has_response_for?(request))
    end
  end
end
