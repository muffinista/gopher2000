module Gopher
  class Request
    attr_accessor :selector, :input, :ip_address

    def initialize(raw, ip_addr=nil)
      @selector, @input = raw.split("\t")
      @ip_address = ip_addr
    end

    def valid?
      # The Selector string should be no longer than 255 characters. (RFC 1436)
      @selector.length <= 255
    end
  end
end
