require 'logger'
require 'singleton'

class Log < Logger

  include Singleton

  class Formatter
  	def call(severity, datetime, progname, msg)
  		datetime_format = "%Y-%m-%d %H:%M:%S"
		  "#{datetime}:\t#{msg}\n"
  	end
  end

end

g = Log.new( "../log/logfile.log", "daily" )
g.info("test")