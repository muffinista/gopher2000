# class WTF < EventMachine::Connection
#   def receive_data data
#     operation = proc {
#       sleep(1)
#       "OH, HELLO!"
#     }
#     callback = proc {|result|
#       result = "1Patch to enable Gopher in IE6	/gopher/clients/ie6	gopher.floodgap.com	70"

#       # do something with result here, such as send it back to a network client.
#       send_data result + [Gopher::Rendering::LINE_ENDING, ".", Gopher::Rendering::LINE_ENDING].join
#       close_connection_after_writing
#     }

#     EventMachine.defer( operation, callback ).inspect
#   end

#   def unbind
#     puts "A connection has terminated"
#   end
# end

module Gopher
  class Server
    attr_accessor :handler

    def host
      @handler.config[:host] || '0.0.0.0'
    end

    def port
      @handler.config[:port] || 70
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

        puts "start server at #{host} #{port}"
        EventMachine::start_server(host, port, h)
        #do |conn|
        #  #@application.reload_stale
        #end
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

  unless ENV['gopher_test']
    at_exit do
      s = Gopher::Server.new(self)
      s.run!
    end
  end
