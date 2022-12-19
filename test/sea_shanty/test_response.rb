#  frozen_string_literal: true

require "test_helper"
require "sea_shanty/response"

module SeaShanty
  class TestResponse < Minitest::Test
    def setup
      @response = Response.new(status: nil, message: nil, headers: nil, body: nil)
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
  end
end
