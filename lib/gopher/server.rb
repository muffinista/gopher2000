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

      ::EM.run do
        puts "start server at #{host} #{port}"
        ::EM.start_server(host, port, @handler) do |conn|
          application.scripts.each do |f|
            if ! @last_reload.nil? && File.mtime(f) > @last_reload
              puts "reloading #{f}"
              load f
            end
          end
          @last_reload = Time.now
          conn.application = @application
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
