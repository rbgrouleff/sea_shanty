#  frozen_string_literal: true

require "test_helper"
require "sea_shanty/response"

module SeaShanty
  class TestResponse < Minitest::Test
    def setup
      @status = 200
      @message = "OK"
      @headers = {}
      @body = "response body"
      @response = Response.new(status: @status, message: @message, headers: @headers, body: @body)
    end

    def test_has_a_status
      assert_respond_to(@response, :status)
    end

    def test_has_a_message
      assert_respond_to(@response, :message)
    end

    def test_has_a_headers
      assert_respond_to(@response, :headers)
    end

    def test_has_a_body
      assert_respond_to(@response, :body)
    end

    def test_has_an_original_response
      assert_respond_to(@response, :original_response)
    end

    def test_to_h_encodes_response_as_hash
      expected = {
        status: {
          code: @status.to_i,
          message: @message
        },
        headers: @headers,
        body: {
          string: @body.to_s,
          encoding: @body.encoding.name
        }
      }
      assert_equal(expected, @response.to_h)
    end

    def test_to_h_handles_nil_body
      response = Response.new(status: @status, message: @message, headers: @headers, body: nil)
      expected = {
        status: {
          code: @status.to_i,
          message: @message
        },
        headers: @headers,
        body: {
          string: "",
          encoding: ""
        }
      }
      assert_equal(expected, response.to_h)
    end

    def test_from_h_instantiates_a_response_from_a_hash
      response = Response.from_h(
        {
          status: {
            code: @status.to_i,
            message: @message
          },
          headers: @headers,
          body: {
            string: @body.to_s,
            encoding: @body.encoding.name
          }
        }
      )
      assert_equal(@status.to_i, response.status)
      assert_equal(@message, response.message)
      assert_equal(@headers, response.headers)
      assert_equal(@body, response.body)
    end

    def test_from_h_recodes_status_to_integer
      response = Response.from_h(
        {
          status: {
            code: @status.to_s,
            message: @message
          },
          headers: @headers,
          body: {
            string: @body.to_s,
            encoding: @body.encoding.name
          }
        }
      )
      assert_equal(@status.to_i, response.status)
      assert_equal(@message, response.message)
      assert_equal(@headers, response.headers)
      assert_equal(@body, response.body)
    end

    def test_from_h_handles_nil_body
      response = Response.from_h(
        {
          status: {
            code: @status.to_s,
            message: @message
          },
          headers: @headers,
          body: {
            string: "",
            encoding: ""
          }
        }
      )
      assert_equal(@status.to_i, response.status)
      assert_equal(@message, response.message)
      assert_equal(@headers, response.headers)
      assert_nil(response.body)
    end

    def test_from_h_handles_empty_body
      response = Response.from_h(
        {
          status: {
            code: @status.to_s,
            message: @message
          },
          headers: @headers,
          body: {
            string: "",
            encoding: "".encoding.name
          }
        }
      )
      assert_equal(@status.to_i, response.status)
      assert_equal(@message, response.message)
      assert_equal(@headers, response.headers)
      assert_equal("", response.body)
    end

    def test_serialize_produces_same_output_as_to_h
      assert_equal(@response.to_h, @response.serialize)
    end

    def test_equality_uses_attribute_equality
      other_response = Response.from_h(@response.to_h)
      assert_equal(@response, other_response)
    end

    def test_equality_treats_string_and_int_status_the_same
      response = Response.new(status: @status.to_s, message: @message, headers: @headers, body: @body)
      other_response = Response.new(status: @status.to_i, message: @message, headers: @headers, body: @body)
      assert_equal(response, other_response)
    end

    def test_equality_with_unequal_response
      response = Response.new(status: @status.to_s, message: @message, headers: @headers, body: @body)
      other_response = Response.new(status: @status.to_i, message: @message, headers: @headers, body: "Not the body #{@body}")
      refute_equal(response, other_response)
    end

    def test_hash_uses_attributes
      other_response = Response.from_h(@response.to_h)
      assert_equal(@response.hash, other_response.hash)
    end

    def test_hash_treats_string_and_int_status_the_same
      response = Response.new(status: @status.to_s, message: @message, headers: @headers, body: @body)
      other_response = Response.new(status: @status.to_i, message: @message, headers: @headers, body: @body)
      assert_equal(response.hash, other_response.hash)
    end

    def test_hash_with_unequal_response
      response = Response.new(status: @status.to_s, message: @message, headers: @headers, body: @body)
      other_response = Response.new(status: @status.to_i, message: @message, headers: @headers, body: "Not the body #{@body}")
      refute_equal(response.hash, other_response.hash)
    end

    def test_was_stored_when_original_response_is_present
      response = Response.new(status: @status, message: @message, headers: @headers, body: @body, original_response: :response)
      assert_predicate(response, :was_stored?)
    end
  end
end
