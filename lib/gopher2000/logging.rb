require 'logging'

module Gopher
  module Logging

    ACCESS_LOG_PATTERN = "%d\t%m\n"
    GOPHER_LOG_PATTERN = ::Logging.layouts.pattern(:pattern => ACCESS_LOG_PATTERN)

    @@access_log = nil
    @@debug_log = nil

    def debug_log(x)
      @@debug_logger ||= ::Logging.logger(STDOUT)
      @@debug_logger.debug x
    end

    def access_log_dest
      self.config && self.config.has_key?(:access_log) ? self.config[:access_log] : STDOUT
    end

    def init_access_log
      log = ::Logging.logger['access_log']
      log.add_appenders(
        ::Logging.appenders.rolling_file(access_log_dest,
          :level => :debug,
          :age => 'daily',
          :layout => GOPHER_LOG_PATTERN)
        )

      log
    end

    def access_log(request, response)
      @@access_logger ||= init_access_log
      code = response.respond_to?(:code) ? response.code : "success"
      size = response.respond_to?(:size) ? response.size : response.length
      output = [request.ip_address, request.selector, request.input, code.to_s, size].join("\t")

      @@access_logger.debug output
    end
  end
end
