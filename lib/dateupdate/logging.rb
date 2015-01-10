require 'log4r'

module Logging
  # Get an instance to a logger configured for the class that includes it.
  # This allows log messages to include the class name
  def logger
    return @logger if @logger

    formatter = Log4r::PatternFormatter.new(:pattern => '[%d] %l %C: %M')

    @logger = Log4r::Logger.new(self.class.name)
    @logger.outputters << Log4r::StdoutOutputter.new('console', {:formatter => formatter})

    @logger
  end
end
