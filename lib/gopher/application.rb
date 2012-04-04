require 'socket'

module Gopher
  class Application < EventMachine::Connection

    include Gopher::Routing
    extend Gopher::Routing

    include Dispatching
    extend Dispatching

    include Helpers
    extend Helpers

    include Rendering
    extend Rendering

    include Logging
    extend Logging

    @routes = []
    @menus = {}
    @scripts ||= []

    cattr_accessor :menus, :routes, :config, :scripts, :last_reload

    class << self
      def host
        config[:host] ||= '0.0.0.0'
      end

      def port
        config[:port] ||= 70
      end

      #
      # check if our script has been updated since the last reload
      #
      def should_reload?
        ! last_reload.nil? && self.scripts.any? do |f|
          File.mtime(f) > last_reload
        end
      end

      #
      # reload scripts if needed
      #
      def reload_stale
        reload_check = should_reload?
        self.last_reload = Time.now

        return if ! reload_check
        reset!

        self.scripts.each do |f|
          debug_log "reload #{f}"
          load f
        end
      end

      #
      # reset the app before reloading any scripts
      #
      def reset!
        self.routes = []
        self.menus = {}
        self.scripts ||= []
        self.config ||= {
          :debug => false,
          :host => "0.0.0.0",
          :port => 70
        }

        register_defaults

        self
      end
    end

    #
    # are we in debugging mode? doesn't really do much now
    #
    def debug_mode?
      config[:debug] == true
    end

    #
    # should we use non-blocking operations? for now, defaults to false if in debug mode,
    # true if we're not in debug mode (presumably, in some sort of production state. HAH!
    # Gopher servers in production)
    #
    def non_blocking?
      config[:non_blocking] ||= ! debug_mode?
    end

    #
    # called by EventMachine when there's an incoming request
    #
    def receive_data(selector)
      # parse out the request
      @request = Request.new(selector, remote_ip)

      operation = proc {
        resp = dispatch(@request)
        access_log(@request, resp)
        resp
      }
      callback = proc {|result|
        send_response result
        close_connection_after_writing
      }

      #
      # if we don't want to block on slow calls, use EM#defer
      # @see http://eventmachine.rubyforge.org/EventMachine.html#M000486
      #
      if non_blocking?
        EventMachine.defer( operation, callback )
      else
        callback.call(operation.call)
      end
    end

    #
    # get the IP address of the client
    #
    def remote_ip
      Socket.unpack_sockaddr_in(get_peername).last
    end

    #
    # send the response back to the client
    #
    def send_response(response)
      case response
      when Gopher::Response then send_response(response.body)
      when String then send_data(response + end_of_transmission)
      when StringIO then send_data(response.read + end_of_transmission)
      when File
        while chunk = response.read(8192) do
          send_data(chunk)
        end
        response.close
      end
    end


    protected
    #
    # Add the period on a line by itself that closes the connection
    #
    # @todo don't add an extra line ending here if we don't need it
    def end_of_transmission
      [Gopher::Rendering::LINE_ENDING, ".", Gopher::Rendering::LINE_ENDING].join
    end

  end
end
