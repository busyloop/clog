# clog

Convenient, context bearing logger for Crystal.


## Features

* **Global macros.**<br>
  Easily log from anywhere in your code. No passing around of Logger instances.
* **Context.**<br>
  Log messages automatically include the calling class and method name for context.<br>
  Additional custom context, persistent per calling instance, can be set at runtime.
* **Easily Customizable. Formatters for JSON and Text included.**<br>
  Look [here](https://github.com/busyloop/clog/tree/master/src/formatters) if you would like to write your own formatter.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     clog:
       github: busyloop/clog
   ```

2. Run `shards install`

## Usage

```crystal
require "clog"

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
    begin
      _info(text: "User changed page", new_page: page_id)
      _context(page: page_id)
    rescue ex : Exception
      _error("An error occurred", ex)
    end
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
```

This gives us the following output:

```
$ crystal examples/basic.cr
I 01-02 23:57:30.647 c=Session#initialize user_id=123 msg="User has arrived!"
I 01-02 23:57:30.647 c=Session#goto user_id=123 text="User changed page" new_page=page1
I 01-02 23:57:30.647 c=Session#goto user_id=123 page=page1 text="User changed page" new_page=page2
I 01-02 23:57:30.647 c=Session#logout user_id=123 page=page2 msg="User logged out"
```

**Notes:**

* Clog automatically includes the calling class and method for context
* By default Clog prints in human readable text format when STDOUT is a tty, otherwise in JSON.
  This auto-switching behavior can be disabled by explicitly setting a formatter.
* After setting a `_context` on a calling instance it will be included in future logging calls from the same instance.



## API

The following macros are available in all classes that `include Clog`:

* `_context(**kwargs)`

  Add context attributes to the calling instance.
  This method is additive. Attributes are added and retained until you clear
  the context with the method below.

* `_context(nil)`
  Clear the context

* `_debug(**kwargs)`
  Log key/value pairs at level _DEBUG_.

* `_debug(message : String)`

  Same as calling `_debug(msg: message)`

* `_debug(ex : Exception)`
  Log an Exception including backtrace

* `_debug(message : String, ex : Exception)`
  Log an Exception plus a custom message

To log at a different log-level use `_info`, `_warn`, `_error`, `_fatal` instead of `_debug`.



## That's all!

Happy logging! :)


## Contributing

1. Fork it (<https://github.com/busyloop/clog/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

