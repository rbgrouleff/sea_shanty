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
  end
end
