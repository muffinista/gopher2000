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
      puts request.inspect
      dispatch(request)
    rescue Exception => e
      "Sorry, there was an error"

      # todo logging etc
    end
  end
end
