module Gopher
  class Server
    attr_accessor :app

    def initialize(a)
      @app = a
    end

    def host
      puts @app.inspect
      @app.config[:host] ||= '0.0.0.0'
    end

    def port
      @app.config[:port] ||= 70
    end

    def run!#(h = Gopher::Application)
#      @app = h

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


        puts "start server at #{host} #{port}"
        EventMachine::start_server(host, port, Gopher::Dispatcher) do |conn|
          conn.app = @app
          #          @handler.reload_stale
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
        op.on('-o addr',   'set the host (default is 0.0.0.0)')             { |val| set :bind, val }
        op.on('-e env',    'set the environment (default is development)')  { |val| set :environment, val.to_sym }
      }.parse!(ARGV.dup)
    end
  end
end
