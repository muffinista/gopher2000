module Gopher

  #
  # main class which will listen on a specified port, and pass requests to an Application class
  #
  class Server
    attr_accessor :app

    #
    # constructor
    # @param [Application] a instance of Gopher::Application we want to run
    #
    def initialize(a)
      @app = a
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
    
    #
    # main app loop. called via at_exit block defined in DSL
    #
    def run!
      EventMachine::run do
        Signal.trap("INT") {
          puts "It's a trap!"
          EventMachine.stop
        }
        Signal.trap("TERM") {
          puts "It's a trap!"
          EventMachine.stop
        }

        EventMachine.kqueue = true if EventMachine.kqueue?
        EventMachine.epoll = true if EventMachine.epoll?


        STDERR.puts "start server at #{host} #{port}"
        if @app.non_blocking?
          STDERR.puts "Not blocking on requests"
        end


        EventMachine::start_server(host, port, Gopher::Dispatcher) do |conn|
          #
          # check if we should reload any scripts before moving along
          #
          @app.reload_stale

          #
          # roughly matching sinatra's style of duping the app to respond
          # to requests, @see http://www.sinatrarb.com/intro#Request/Instance%20Scope
          #
          # this essentially means we have 'one instance per request'
          #
          conn.app = @app.dup
        end
      end
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
