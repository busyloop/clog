require "log"

# A `Log::Backend` that proxies to Clog.
class Clog::Backend < ::Log::Backend
  EMPTY_CONTEXT = {} of String => String

  def initialize # settings
    # @mutex = Mutex.new(:unchecked)
    # @progname = File.basename(PROGRAM_NAME)
  end

  def write(entry : ::Log::Entry)
    if ex = entry.exception
      Clog::Settings.log(entry.severity.to_i, entry.source, EMPTY_CONTEXT, entry.message, ex)
    else
      Clog::Settings.log(entry.severity.to_i, entry.source, EMPTY_CONTEXT, entry.message)
    end
    # @mutex.synchronize do
    #   format(entry)
    #   io.puts
    #   io.flus}}h
    # end
  end
end
