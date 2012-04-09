module Gopher
  class Server
    attr_accessor :handler

    def host
      @handler.config[:host] ||= '0.0.0.0'
    end

    def port
      @handler.config[:port] ||= 70
    end

    def run!(h = Gopher::Application)
      @handler = h

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
        EventMachine::start_server(host, port, h) do |conn|
          @handler.reload_stale
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

#
# don't call at_exit if we're running specs
#
unless ENV['gopher_test']
  at_exit do
    s = Gopher::Server.new(self)
    s.run!
  end
end
