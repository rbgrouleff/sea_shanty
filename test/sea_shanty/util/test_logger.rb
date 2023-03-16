# frozen_string_literal: true

require "test_helper"
require "sea_shanty/util/logger"
require "stringio"

module SeaShanty
  class TestLogger < Minitest::Test
    def setup
      @dir = Dir.mktmpdir("sea_shanty")
    end

    def teardown
      FileUtils.remove_entry(@dir)
    end

    def test_initialize_with_a_file_object
      File.open(File.join(@dir, "#{__method__}.log"), "a+") do |file|
        logger = Logger.new(file)

        assert_equal file, logger.destination
      end
    end

    def test_initialize_with_a_writable_object
      io = StringIO.new
      logger = Logger.new(io)

      assert_equal io, logger.destination
    end

    def test_initialize_with_a_path_string
      path = File.join(@dir, "#{__method__}.log")
      logger = Logger.new(path)

      assert_kind_of File, logger.destination
      assert_equal path, logger.destination.path

      logger.destination.close
    end

    def test_log_writes_to_destination
      message = "the log message\n"
      destination = StringIO.new
      logger = Logger.new(destination)
      logger.log(message)

      assert_equal message, destination.string
    end

    def test_log_appends_missing_newline
      message = "the log message"
      destination = StringIO.new
      logger = Logger.new(destination)
      logger.log(message)

      assert_equal "#{message}\n", destination.string
    end

    def test_null_logger
      logger = Logger::NullLogger.new

      assert_respond_to logger, :log
    end
  end
end
