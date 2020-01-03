class Clog::Formatter::KeyValue < Clog::Formatter
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
    @io << severity.to_s[0].to_s
    @io << " "
    @io << timestamp.to_s("%m-%d %H:%M:%S.%3N")
    bt = nil
    data.each do |k, v|
      @io << " "
      @io << k
      @io << "="
      if k == "backtrace" && v.is_a? Array(String)
        @io << "see_below"
        bt = v
      else
        if v.is_a?(String) && v.includes? " "
          @io << "\""
          @io << v.gsub("\"", "\\\"")
          @io << "\""
        else
          @io << v
        end
      end
    end
    @io << "\n"
    unless bt.nil?
      @io << "--- "
      @io << data["exception"]
      @io << ": "
      @io << data["error"]
      @io << " ---\n"
      @io << bt.join("\n")
      @io << "\n---\n"
    end
  end
end
