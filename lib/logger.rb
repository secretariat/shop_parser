require 'logger'

class Log
	def initialize
		@logger ||= Logger.new( "logfile.log", "daily" )
		original_formatter = Logger::Formatter.new
		@logger.formatter = proc { |severity, datetime, progname, msg|
		  original_formatter.call(severity, datetime, progname, msg.dump)
		}
	end

	def write message
		@logger.info message
	end

end

g = Log.new
g.write "test"