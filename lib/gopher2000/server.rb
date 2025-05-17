# frozen_string_literal: true

require "nio"
require "socket"

module Gopher

  #
  # main class which will listen on a specified port, and pass requests to an Application class
  #
  class Server
    attr_accessor :app, :exit
    attr_reader :status

    #
    # constructor
    # @param [Application] a instance of Gopher::Application we want to run
    #
    def initialize(a)
      @app = a
      @status = :new
    end
 
    #
    # @return [String] name of the host specified in our config
    #
    def host
      @app.config[:host] ||= '0.0.0.0'
    end

    #
    # @return [Integer] port specified in our config
    #
    def port
      @app.config[:port] ||= 70
    end

    #
    # @return [String] environment specified in config
    #
    def env
      @app.config[:env] || 'development'
    end


    def accept
      socket = @server.accept
      _, port, host = socket.peeraddr
      
      monitor = @selector.register(socket, :r)
      monitor.value = proc { read(socket) }
    end

    def read(socket)
      Dispatcher.new(app, socket).read!
    rescue EOFError
      _, port, host = socket.peeraddr
    ensure
      @selector.deregister(socket)
      socket.close
    end
    
    #
    # main app loop. called via at_exit block defined in DSL
    #
    def run!(background=true)
      if background
        @thread = Thread.new { run_server }
      else
        run_server
      end
    end

    def stop
      @status = :stop
    end
    
    def run_server      
      @selector = NIO::Selector.new
      puts "Listening on #{host}:#{port}"
      @server = TCPServer.new(host, port)
      
      monitor = @selector.register(@server, :r)
      monitor.value = proc { accept }

      @status = :run

      Signal.trap("INT") {
        puts "It's a trap!"
        @status = :stop
      }
      Signal.trap("TERM") {
        puts "It's a trap!"
        @status = :stop
      }

      # todo this could probably be a thread with a loop
      while @status == :run do
        #
        # check if we should reload any scripts before moving along
        #
        @app.reload_stale

        @selector.select(1) { |monitor| monitor.value.call }
      end

      @server.close

      #  STDERR.puts "start server at #{host} #{port}"
      #  if @app.non_blocking?
      #    STDERR.puts "Not blocking on requests"
      #  end
    end
    


    #
    # don't try and parse arguments if someone already has done that
    #
    if ARGV.any? && ! defined?(OptionParser)
      require 'optparse'
      OptionParser.new { |op|
        op.on('-p port',   'set the port (default is 70)')                { |val| set :port, Integer(val) }
        op.on('-o addr',   'set the host (default is 0.0.0.0)')             { |val| set :host, val }
        op.on('-e env',    'set the environment (default is development)')  { |val| set :env, val.to_sym }
      }.parse!(ARGV.dup)
    end
  end
end
