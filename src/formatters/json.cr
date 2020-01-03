class Clog::Formatter::JSON < Clog::Formatter
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

  def format(timestamp, severity, data) : Nil
    {s: severity.to_s[0].upcase.to_s, t: Time::Format::ISO_8601_DATE_TIME.format(timestamp)}.to_h.merge(data).to_json(@io)
    @io << "\n"
  end
end
