require 'logging'

module Gopher
  module Logging
    attr_accessor :config

    def use_debug_log?
      @config && @config.has_key?(:debug) ? @config[:debug] == true : false
    end

    def access_log_dest
      @config && @config.has_key?(:log_dest) ? @config[:log_dest] : STDOUT
    end

    def debug_log(x)
      return if ! use_debug_log?
      @debug_logger ||= ::Logging.logger(STDOUT)
      @debug_logger.debug x
    end

    def access_log(request, response)
      @access_logger ||= ::Logging.logger(access_log_dest)

      code = response.respond_to?(:code) ? response.code : "success"
      size = response.respond_to?(:size) ? response.size : response.length
      x = [request.ip_address, request.selector, request.input, code.to_s, size].join(" ")

      @access_logger.debug x
    end
  end
end
