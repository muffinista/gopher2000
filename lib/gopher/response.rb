module Gopher
  class Response
    attr_accessor :body
    attr_accessor :code

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
