module Gopher

  #
  # basic class for an incoming request
  #
  class Request
    attr_accessor :selector, :input, :ip_address

    def initialize(raw, ip_addr=nil)
      @raw = raw
      @selector, @input = @raw.chomp.split("\t")
      
	    @selector = Gopher::Application.sanitize_selector(@selector)
	    @ip_address = ip_addr
    end

    def url?
      @raw.match?(/^URL\:/)
    end

    def url
      @raw.chomp.split("\t").first.gsub(/^URL\:/, '')
    end
    
    # confirm that this is actually a valid gopher request
    # @return [Boolean] true if the request is valid, false otherwise
    def valid?
      # The Selector string should be no longer than 255 characters. (RFC 1436)
      @selector.length <= 255
    end
  end
end
