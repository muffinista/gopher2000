module Gopher
  class Handler
    def initialize(selector, ip)
      @selector = selector
      @ip = ip
    end

    def request
      @_request ||= Request.new(@selector, @ip)
    end

    def handle_not_found
      # look for a 404 template

      # if none, spit out default text
    end

    def handle
      begin
        application.dispatch(request)

      rescue Gopher::NotFoundError => e
        handle_not_found
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
