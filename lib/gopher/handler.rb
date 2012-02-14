# module Gopher
#   class Handler
#     def initialize(selector, ip)
#       @selector = selector
#       @ip = ip
#     end

#     def request
#       @_request ||= Request.new(@selector, @ip)
#     end

#     def handle
#       application.dispatch(request)
#     rescue => e
#       #        Gopher.logger.error "Bad juju afoot. #{e}"; puts e
#       raise e
#     end
#   end
# end
