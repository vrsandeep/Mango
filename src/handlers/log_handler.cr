require "kemal"
require "../logger"

class LogHandler < Kemal::BaseLogHandler
  def call(context : HTTP::Server::Context)
    elapsed_time = Time.measure { call_next context }
    elapsed_text = elapsed_text elapsed_time
    msg = "#{context.response.status_code} #{context.request.method}" \
          " #{context.request.resource} #{elapsed_text}"
    Logger.debug msg
    context
  end

  def write(message : String)
    Logger.debug message
  end

  private def elapsed_text(elapsed : Time::Span) : String
    millis = elapsed.total_milliseconds
    return "#{millis.round(2)}ms" if millis >= 1
    "#{(millis * 1000).round(2)}µs"
  end
end
