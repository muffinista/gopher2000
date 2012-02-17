module Gopher
  class Server
    attr_accessor :application, :config
    def initialize(app, host = '0.0.0.0', port = 70, handler = Gopher::Connection)
      @application = app
      @config = {}
      @config[:host] = host
      @config[:port] = port

      @handler = handler
    end

    def host
      @config[:host]
    end

    def port
      @config[:port]
    end

    def run!
      trap("INT") { exit }

      #class Server < EventMachine::Connection
      #    attr_accessor :options, :status
      #end
      #
      #EM.run do
      #    EM.start_server 'localhost', 8080, Server do |conn|
      #        conn.options = {:my => 'options'}
      #        conn.status = :OK
      #    end
      #end

      ::EM.run do
        puts "start server at #{host} #{port}"
        ::EM.start_server(host, port, @handler) do |conn|
          conn.application = @application
        end
      end
    end


    if ARGV.any?
      require 'optparse'
      OptionParser.new { |op|
        op.on('-p port',   'set the port (default is 4567)')                { |val| set :port, Integer(val) }
        op.on('-o addr',   'set the host (default is 0.0.0.0)')             { |val| set :bind, val }
        op.on('-e env',    'set the environment (default is development)')  { |val| set :environment, val.to_sym }
      }.parse!(ARGV.dup)
    end
  end
end
