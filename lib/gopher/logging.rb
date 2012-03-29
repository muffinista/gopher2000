require 'logging'

module Gopher
  module Logging
    def debug_log(x)
      @debug_logger ||= ::Logging.logger(STDOUT)
      @debug_logger.debug x
    end

    def access_log(x)
      @access_logger ||= ::Logging.logger(STDOUT)
      @access_logger.debug x
    end
  end
end
