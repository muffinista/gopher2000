module Gopher
  class Request
    attr_accessor :selector, :input, :ip_address

    def initialize(raw, ip_addr=nil)
      @selector, @input = raw.split("\t")
      @ip_address = ip_addr
    end
  end
end
