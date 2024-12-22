require "log"
require "colorize"

class Logger
  LEVELS       = ["debug", "error", "fatal", "info", "warn"]
  SEVERITY_IDS = [Log::Severity::Debug, Log::Severity::Error,
                  Log::Severity::Fatal, Log::Severity::Info, Log::Severity::Warn]
  COLORS = [:light_cyan, :light_red, :red, :light_yellow, :light_magenta]

  getter raw_log = Log.for ""

  @@severity : Log::Severity = :info

  use_default

  def initialize
    @@severity = Logger.get_severity
    @backend = Log::IOBackend.new

    format_proc = ->(entry : Log::Entry, io : IO) do
      color = :default
      {% begin %}
        case entry.severity.label.to_s().downcase
          {% for lvl, i in LEVELS %}
          when {{lvl}}, "#{{{lvl}}}ing"
            color = COLORS[{{i}}]
          {% end %}
        else
        end
      {% end %}

      io << "[#{entry.severity.label}]".ljust(10).colorize(color)
      io << entry.timestamp.to_s("%Y/%m/%d %H:%M:%S") << " | "
      io << entry.message
    end

    @backend.formatter = Log::Formatter.new &format_proc

    Log.setup do |c|
      c.bind "*", @@severity, @backend
      c.bind "db.*", :error, @backend
      c.bind "duktape", :none, @backend
    end
  end

  def self.get_severity(level = "") : Log::Severity
    if level.empty?
      level = Config.current.log_level
    end
    {% begin %}
      case level.downcase
      when "off"
        return Log::Severity::None
        {% for lvl, i in LEVELS %}
          when {{lvl}}
          return SEVERITY_IDS[{{i}}]
        {% end %}
      else
        raise "Unknown log level #{level}"
      end
    {% end %}
  end

  # Ignores @@severity and always log msg
  def log(msg)
    @backend.write Log::Entry.new "", Log::Severity::None, msg,
      Log::Metadata.empty, nil
  end

  def log(msg : Exception, severity)
    @backend.write(Log::Entry.new "", severity, "",
      Log::Metadata.empty, msg)
    if exception_message = msg.message
      @backend.write(Log::Entry.new "", severity, exception_message,
        Log::Metadata.empty, nil)
    end
    if message_backtrace = msg.backtrace.try &.join("\n")
      @backend.write(Log::Entry.new "", severity, message_backtrace,
        Log::Metadata.empty, nil)
    end
  end

  def log(msg : String, severity)
    @backend.write Log::Entry.new "", severity, msg,
      Log::Metadata.empty, nil
  end

  def log(msg, severity)
    log msg.to_s, @@severity
  end

  def self.log(msg)
    default.log msg
  end

  {% for lvl in LEVELS %}
    def {{lvl.id}}(msg)
      log(msg, Logger.get_severity("{{lvl.id}}"))
    end
    def self.{{lvl.id}}(msg)
      default.not_nil!.{{lvl.id}} msg
    end
  {% end %}
end
