require "json"

class Clog::Settings
  LOG_LEVELS = %w(DEBUG VERBOSE INFO WARN ERROR FATAL)

  class_property formatter : Formatter = (STDOUT.tty? ? Formatter::KeyValue.new(STDOUT) : Formatter::JSON.new(STDOUT))
  class_property utc : Bool = false
  class_getter log_level : Int32 = LOG_LEVELS.index("INFO").not_nil!

  @@mutex = Mutex.new

  def self.log_level=(level : Int32)
    raise ArgumentError.new("level must be between >= 0 and <= #{LOG_LEVELS_SIZE - 1}") unless level > -1 && level < LOG_LEVELS.size - 1
    @@log_level = level
  end

  def self.log_level=(level_name : String)
    @@log_level = LOG_LEVELS.index(level_name.upcase) || 1
  end

  def self.timestamp
    @@utc ? Time.utc : Time.local
  end

  def self.context_for(instance)
    instance.log_context
  end

  def self.context_for(klass : Class)
    {} of String => String
  end

  def self.log(level, source, log_context, payload)
    @@mutex.synchronize {
      Clog::Settings.formatter.format(timestamp, LOG_LEVELS[level], { c: source }.to_h.merge(log_context).merge(payload.to_h))
    }
  end

  def self.log(level, source, log_context, payload : String)
    log_payload = {} of String => String
    log_payload[Clog::Settings.formatter.key_message] = payload
    log(level, source, log_context, log_payload)
  end

  def self.log(level, source, log_context, payload : Exception)
    log_payload = {} of String => String | Array(String)
    log_payload[Clog::Settings.formatter.key_exception_message] = payload.message || ""
    log_payload[Clog::Settings.formatter.key_exception] = payload.class.name
    log_payload[Clog::Settings.formatter.key_backtrace] = payload.backtrace
    log(level, source, log_context, log_payload)
  end

  def self.log(level, source, log_context, message : String, ex : Exception)
    log_payload = {} of String => String | Array(String)
    log_payload[Clog::Settings.formatter.key_message] = message
    log_payload[Clog::Settings.formatter.key_exception_message] = ex.message || ""
    log_payload[Clog::Settings.formatter.key_exception] = ex.class.name
    log_payload[Clog::Settings.formatter.key_backtrace] = ex.backtrace
    log(level, source, log_context, log_payload)
  end
end

abstract class Clog::Formatter
  def initialize(@io : IO)
  end

  def key_message
    "msg"
  end

  def key_exception
    "exception"
  end

  def key_exception_message
    "error"
  end

  def key_backtrace
    "backtrace"
  end

  abstract def format(timestamp, severity, data) : Nil
end

module Clog
  @[JSON::Field(ignore: true)]
  getter log_context = {} of Symbol => Nil | Bool | Int8 | Int16 | Int32 | Int64 | UInt8 | UInt16 | UInt32 | UInt64 | Float32 | Float64 | String | Symbol

  def _context(**data)
    @log_context = @log_context.merge(data.to_h)
  end

  def _context(clear)
    @log_context.clear
  end

  def _clog_context
    @log_context
  end

  {% for llname, ll in Clog::Settings::LOG_LEVELS %}
    # call with kwargs
    macro _{{llname.id.downcase}}(**payload)
      unless Clog::Settings.log_level > {{ll}}
        Clog::Settings.log({{ll}}, "\{{@type}}#{self.is_a?(Class) ? "." : "#"}\{{@def.name}}", Clog::Settings.context_for(self), \{{payload}})
      end
    end

    # call with String or Exception
    macro _{{llname.id.downcase}}(payload)
      unless Clog::Settings.log_level > {{ll}}
        Clog::Settings.log({{ll}}, "\{{@type}}#{self.is_a?(Class) ? "." : "#"}\{{@def.name}}", Clog::Settings.context_for(self), \{{payload}})
      end
    end

    # call with String and Exception
    macro _{{llname.id.downcase}}(message, ex)
      unless Clog::Settings.log_level > {{ll}}
        Clog::Settings.log({{ll}}, "\{{@type}}#{self.is_a?(Class) ? "." : "#"}\{{@def.name}}", Clog::Settings.context_for(self), \{{message}}, \{{ex}})
      end
    end
  {% end %}
end

require "./backend"
require "./formatters/key_value"
require "./formatters/json"
