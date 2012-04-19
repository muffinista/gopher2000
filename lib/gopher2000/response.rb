module Gopher

  #
  # basic class for server response to a request. contains the
  # rendered results, a code that indicates success/failure, and can
  # report the size of the response
  #
  class Response
    attr_accessor :body
    attr_accessor :code

    #
    # get the size, in bytes, of the response. used for logging
    # @return [Integer] size
    #
    def size
      case self.body
      when String then self.body.length
      when StringIO then self.body.length
      when File then self.body.size
      else 0
      end
    end
  end
end
