require "timecop"
require "./spec_helper"

class TestClass
  include Clog

  getter io

  def initialize
    @io = IO::Memory.new
  end

  def reset
    ret = @io.to_s
    @io.clear
    ret
  end

  def clear_context
    _context(nil)
  end

  def debug_string
    _debug("hello world")
    reset
  end

  def debug_kwargs
    _debug(text: "hello world")
    reset
  end

  def debug_string_with_context
    _context(ctx: "foobar")
    _debug("hello world")
    reset
  end

  def debug_kwargs_with_context
    _context(ctx: "foobar")
    _debug(text: "hello world")
    reset
  end

  def error_with_exception
    begin
      raise ArgumentError.new("kaputt")
    rescue ex : Exception
      _error(ex)
    end
    reset
  end

  def error_with_message_and_exception
    begin
      raise ArgumentError.new("kaputt")
    rescue ex : Exception
      _error("didn't work", ex)
    end
    reset
  end

  def self.c_debug_string
    _debug("hello world")
  end

  def self.c_debug_kwargs
    _debug(text: "hello world")
  end
end

describe Clog do
  describe Clog::Formatter::KeyValue do
    it "works" do
      Timecop.freeze(Time.utc(1990, 8, 8, 0, 0)) do
        c = TestClass.new
        Clog::Settings.formatter = Clog::Formatter::KeyValue.new(c.io)
        Clog::Settings.log_level = "DEBuG"
        c.debug_string.should eq "D 08-08 00:00:00.000 c=TestClass#debug_string msg=\"hello world\"\n"
        c.debug_kwargs.should eq "D 08-08 00:00:00.000 c=TestClass#debug_kwargs text=\"hello world\"\n"

        c.debug_string_with_context.should eq "D 08-08 00:00:00.000 c=TestClass#debug_string_with_context ctx=foobar msg=\"hello world\"\n"

        # context should stick around
        c.debug_string.should eq "D 08-08 00:00:00.000 c=TestClass#debug_string ctx=foobar msg=\"hello world\"\n"
        c.clear_context

        # context should be gone
        c.debug_string.should eq "D 08-08 00:00:00.000 c=TestClass#debug_string msg=\"hello world\"\n"

        # bring it back
        c.debug_kwargs_with_context.should eq "D 08-08 00:00:00.000 c=TestClass#debug_kwargs_with_context ctx=foobar text=\"hello world\"\n"

        # context should stick around
        c.debug_string.should eq "D 08-08 00:00:00.000 c=TestClass#debug_string ctx=foobar msg=\"hello world\"\n"

        c.error_with_exception.should start_with "E 08-08 00:00:00.000 c=TestClass#error_with_exception ctx=foobar error=kaputt exception=ArgumentError backtrace=see_below\n--- ArgumentError: kaputt ---\nspec/clog_spec.cr"
        c.error_with_message_and_exception.should start_with "E 08-08 00:00:00.000 c=TestClass#error_with_message_and_exception ctx=foobar msg=\"didn't work\" error=kaputt exception=ArgumentError backtrace=see_below\n--- ArgumentError: kaputt ---\nspec/clog_spec"

        TestClass.c_debug_string
        c.reset.should eq "D 08-08 00:00:00.000 c=TestClass.c_debug_string msg=\"hello world\"\n"
        TestClass.c_debug_kwargs
        c.reset.should eq "D 08-08 00:00:00.000 c=TestClass.c_debug_kwargs text=\"hello world\"\n"
      end
    end
  end

  describe Clog::Formatter::JSON do
    it "works" do
      Timecop.freeze(Time.local(1990, 8, 8, 0, 0)) do
        c = TestClass.new
        Clog::Settings.formatter = Clog::Formatter::JSON.new(c.io)
        Clog::Settings.log_level = "dEBUg"
        c.debug_string.should eq "{\"s\":\"D\",\"t\":\"1990-08-08T00:00:00+02:00\",\"c\":\"TestClass#debug_string\",\"msg\":\"hello world\"}\n"
        c.debug_kwargs.should eq "{\"s\":\"D\",\"t\":\"1990-08-08T00:00:00+02:00\",\"c\":\"TestClass#debug_kwargs\",\"text\":\"hello world\"}\n"

        c.debug_string_with_context.should eq "{\"s\":\"D\",\"t\":\"1990-08-08T00:00:00+02:00\",\"c\":\"TestClass#debug_string_with_context\",\"ctx\":\"foobar\",\"msg\":\"hello world\"}\n"

        # context should stick around
        c.debug_string.should eq "{\"s\":\"D\",\"t\":\"1990-08-08T00:00:00+02:00\",\"c\":\"TestClass#debug_string\",\"ctx\":\"foobar\",\"msg\":\"hello world\"}\n"
        c.clear_context

        # context should be gone
        c.debug_string.should eq "{\"s\":\"D\",\"t\":\"1990-08-08T00:00:00+02:00\",\"c\":\"TestClass#debug_string\",\"msg\":\"hello world\"}\n"

        # bring it back
        c.debug_kwargs_with_context.should eq "{\"s\":\"D\",\"t\":\"1990-08-08T00:00:00+02:00\",\"c\":\"TestClass#debug_kwargs_with_context\",\"ctx\":\"foobar\",\"text\":\"hello world\"}\n"

        # context should stick around
        c.debug_string.should eq "{\"s\":\"D\",\"t\":\"1990-08-08T00:00:00+02:00\",\"c\":\"TestClass#debug_string\",\"ctx\":\"foobar\",\"msg\":\"hello world\"}\n"

        c.error_with_exception.should start_with "{\"s\":\"E\",\"t\":\"1990-08-08T00:00:00+02:00\",\"c\":\"TestClass#error_with_exception\",\"ctx\":\"foobar\",\"error\":\"kaputt\",\"exception\":\"ArgumentError\",\"backtrace\":[\"spec/clog_spec.cr"
        c.error_with_message_and_exception.should start_with "{\"s\":\"E\",\"t\":\"1990-08-08T00:00:00+02:00\",\"c\":\"TestClass#error_with_message_and_exception\",\"ctx\":\"foobar\",\"msg\":\"didn't work\",\"error\":\"kaputt\",\"exception\":\"ArgumentError\",\"backtrace\":[\"spec/clog_spec"

        TestClass.c_debug_string
        c.reset.should eq "{\"s\":\"D\",\"t\":\"1990-08-08T00:00:00+02:00\",\"c\":\"TestClass.c_debug_string\",\"msg\":\"hello world\"}\n"
        TestClass.c_debug_kwargs
        c.reset.should eq "{\"s\":\"D\",\"t\":\"1990-08-08T00:00:00+02:00\",\"c\":\"TestClass.c_debug_kwargs\",\"text\":\"hello world\"}\n"
      end
    end
  end
end
