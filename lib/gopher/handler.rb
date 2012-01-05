module Gopher
  class Handler
    def initialize(selector, ip)
      @selector = selector
      @ip = ip
    end

    def request
      @_request ||= Request.new(@selector, @ip)
    end

    def handle
      begin
        application.dispatch(request)

      rescue Gopher::NotFound => e
#        Gopher.logger.error "Unknown selector. #{e}"
      rescue Gopher::InvalidRequest => e
#        Gopher.logger.error "Invalid request. #{e}"
      rescue => e
#        Gopher.logger.error "Bad juju afoot. #{e}"; puts e
        raise e
      end
    end
  end
end
