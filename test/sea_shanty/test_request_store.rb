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
      @request_store.store(@request_store.request_file_path(@request), @request, @response)
      assert_path_exists(path_for_request(@request))
    end

    def test_the_stored_request_includes_the_response
      @request_store.store(@request_store.request_file_path(@request), @request, @response)
      serialized_file_content = YAML.safe_load(path_for_request(@request).read, permitted_classes: [Symbol])
      assert_operator(serialized_file_content, :has_key?, :response)
      assert_equal(@response.to_h, serialized_file_content.fetch(:response))
    end

    def test_the_stored_request_includes_the_request
      @request_store.store(@request_store.request_file_path(@request), @request, @response)
      serialized_file_content = YAML.safe_load(path_for_request(@request).read, permitted_classes: [Symbol])
      assert_operator(serialized_file_content, :has_key?, :request)
      assert_equal(@request.to_h, serialized_file_content.fetch(:request))
    end

    def test_the_stored_request_includes_the_time_of_saving
      @request_store.store(@request_store.request_file_path(@request), @request, @response)
      expected = DateTime.parse(DateTime.now.to_s)
      serialized_file_content = YAML.safe_load(path_for_request(@request).read, permitted_classes: [Symbol])
      assert_operator(serialized_file_content, :has_key?, :stored_at)
      assert_equal(expected, DateTime.parse(serialized_file_content.fetch(:stored_at)))
    end

    def test_it_has_the_reponse_for_a_stored_request
      path = @request_store.request_file_path(@request)
      @request_store.store(path, @request, @response)
      assert_predicate(path, :exist?)
    end

    def test_it_has_the_response_when_a_generic_response_regex_matches_request_url
      generic_request = Request.new(method: :get, url: URI.parse("https://example.com/generic/1234"), headers: {}, body: nil)
      generic_response = Response.new(status: 200, message: "OK", headers: {}, body: "generic response")

      @request_store.store(@request_store.request_file_path(generic_request), generic_request, generic_response)
      @config.generic_responses[/\/generic\//] = path_for_request(generic_request).to_s

      actual_request = Request.new(method: :get, url: URI.parse("https://example.com/generic/actual"), headers: {}, body: nil)

      actual_response = @request_store.fetch(actual_request) do
        raise "NOPE"
      end

      assert_equal(generic_response, actual_response)
    end

    def test_it_ensures_generic_response_path_is_relative_to_storage_dir
      generic_request = Request.new(method: :get, url: URI.parse("https://example.com/generic/1234"), headers: {}, body: nil)
      generic_response = Response.new(status: 200, message: "OK", headers: {}, body: "generic response")
      @request_store.store(@request_store.request_file_path(generic_request), generic_request, generic_response)
      @config.generic_responses[/\/generic\//] = path_for_request(generic_request).to_s
      actual_request = Request.new(method: :get, url: URI.parse("https://example.com/generic/actual"), headers: {}, body: nil)
      actual_response = @request_store.fetch(actual_request) do
        raise "NOPE"
      end

      assert_equal(generic_response, actual_response)
    end

    def test_it_passes_to_block_when_generic_response_regex_does_not_match_request_url
      generic_request = Request.new(method: :get, url: URI.parse("https://example.com/generic/1234"), headers: {}, body: nil)
      generic_response = Response.new(status: 200, message: "OK", headers: {}, body: "generic response")
      @request_store.store(@request_store.request_file_path(generic_request), generic_request, generic_response)
      @config.generic_responses[/\/generic\//] = path_for_request(generic_request).to_s
      actual_request = Request.new(method: :get, url: URI.parse("https://example.com/not_generic/actual"), headers: {}, body: nil)
      expected_response = Response.new(status: 200, message: "OK", headers: {}, body: "NOT generic response")
      actual_response = @request_store.fetch(actual_request) do
        expected_response
      end

      assert_equal(expected_response, actual_response)
    end

    def test_load_response_finds_the_response_for_a_stored_request
      path = @request_store.request_file_path(@request)
      @request_store.store(path, @request, @response)
      assert_equal(@response, @request_store.load_response(path, @request))
    end

    def test_load_response_raises_if_request_is_unknown
      method = :put
      refute_equal(method, @request.method)
      request = Request.new(method: method, url: @request.url, headers: @request.headers, body: @request.body)
      path = @request_store.request_file_path(request)
      assert_raises(UnknownRequest) { @request_store.load_response(path, request) }
    end

    def test_load_response_can_load_time_instances_in_the_yaml
      @response.headers["date"] = Time.now
      path = @request_store.request_file_path(@request)
      @request_store.store(path, @request, @response)
      response = @request_store.load_response(path, @request)
      assert_equal(@response, response)
    end

    def test_load_response_can_load_datetime_instances_in_the_yaml
      @response.headers["date"] = DateTime.now
      path = @request_store.request_file_path(@request)
      @request_store.store(path, @request, @response)
      response = @request_store.load_response(path, @request)
      assert_equal(@response, response)
    end

    def test_fetch_returns_stored_response
      @request_store.store(@request_store.request_file_path(@request), @request, @response)
      returned_response = @request_store.fetch(@request) do
        raise "NOPE"
      end

      assert_equal(@response, returned_response)
    end

    def test_fetch_stores_response_for_unknown_request
      refute_predicate(@request_store.request_file_path(@request), :exist?)
      @request_store.fetch(@request) do
        @response
      end

      assert_predicate(@request_store.request_file_path(@request), :exist?)
    end

    def test_fetch_returns_stored_response_after_storing_it
      refute_predicate(@request_store.request_file_path(@request), :exist?)
      returned_response = @request_store.fetch(@request) do
        @response
      end

      assert_predicate(@request_store.request_file_path(@request), :exist?)
      assert_equal(@response, returned_response)
    end

    def test_fetch_fails_when_readonly_and_response_is_not_stored
      @config.readonly = true

      assert_raises(UnknownRequest) { @request_store.fetch(@request) { @response } }
    end

    def test_fetch_returns_stored_response_when_readonly
      @config.readonly = true
      @request_store.store(@request_store.request_file_path(@request), @request, @response)
      returned_response = @request_store.fetch(@request) { raise "NOPE" }

      assert_equal(@response, returned_response)
    end

    def test_fetch_does_not_store_response_when_bypass_is_set_and_response_is_not_stored
      @config.bypass = true

      refute_predicate(@request_store.request_file_path(@request), :exist?)
      returned_response = @request_store.fetch(@request) { @response }

      refute_predicate(@request_store.request_file_path(@request), :exist?)
      assert_equal(@response, returned_response)
    end

    def test_fetch_returns_response_from_block_if_it_has_a_stored_response_when_bypass_is_set
      @config.bypass = true
      @request_store.store(@request_store.request_file_path(@request), @request, @response)
      expected_response = Response.new(status: 302, message: "Temporary redirect", headers: {"Location" => "https://example.com/redirected"}, body: nil)
      returned_response = @request_store.fetch(@request) { expected_response }

      assert_equal(expected_response, returned_response)
    end

    def test_fetch_fails_if_bypass_and_readonly_are_both_true
      @config.bypass = true
      @config.readonly = true

      assert_raises(ConfigurationError) { @request_store.fetch(@request) { raise "NOPE" } }
    end

    private

    def path_for_request(request)
      serializer = RequestSerializer.new
      Pathname(@dir).join(serializer.file_path(request))
    end
  end
end
