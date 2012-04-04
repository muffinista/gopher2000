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

      def reset!
        self.routes = []
        self.menus = {}
        self.scripts ||= []
        self.config ||= {}

        register_defaults

        self
      end
    end

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

      EventMachine.defer( operation, callback )
    end

    def remote_ip
      Socket.unpack_sockaddr_in(get_peername).last
    end

    #
    # @todo work on end_of_transmission call
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
