require 'log_buddy'

Dir.mkdir(PROJECT_ROOT + '/logs') if !File.exists?(PROJECT_ROOT + '/logs')

MONGO_LOGGER = Logger.new(PROJECT_ROOT + '/logs/mongomapper.log')

LogBuddy.init(
  :disabled => ENV['RACK_ENV'] == 'test', 
  :log_to_stdout => false, # strange, but without this d() logs everything twice
  :use_awesome_print => true
)

class MultiIO
  def initialize(*targets)
     @targets = targets
  end

  def write(*args)
    @targets.each {|t| t.write(*args)}
  end

  def close
    @targets.each(&:close)
  end
end

# Auto per-class logging for the various spiders
module SpiderLogging
  def log
    @log ||= SpiderLogging.logger_for(self.class.name)
  end

  # Use a hash class-ivar to cache a unique Logger per class:
  @loggers = {}

  class << self
    def logger_for(classname)
      @loggers[classname] ||= configure_logger_for(classname)
    end

    def configure_logger_for(classname)
      file = File.open(PROJECT_ROOT + "/logs/#{classname}.log", "a")
      Logger.new MultiIO.new(STDOUT, file)
    end
  end
end