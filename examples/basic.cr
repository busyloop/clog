require "../src/clog"

# Optionally set the log level to one of DEBUG INFO WARN ERROR FATAL
# (defaults to INFO, the value is case-insensitive)
# Clog::Settings.log_level = "INFO"

# Uncomment one of the two lines below to force a specific output format
# (by default KeyValue is used when STDOUT is a tty, otherwise JSON)
# Clog::Settings.formatter = Clog::Formatter::KeyValue.new(STDOUT)
# Clog::Settings.formatter = Clog::Formatter::JSON.new(STDOUT)

# And now a quick example...
class Session
  # Include Clog in all classes where you
  # want the logging macros to be available.
  include Clog

  def initialize(user_id)
    _context(user_id: user_id)
    _info("User has arrived!")
  end

  def goto(page_id)
    _info(text: "User changed page", new_page: page_id)
    _context(page: page_id)
  end

  def logout
    _info("User logged out")
    _context(nil)
  end
end

s = Session.new(123)
s.goto("page1")
s.goto("page2")
s.logout
