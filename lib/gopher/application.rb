module Gopher
  class Application

    include Routing
    include Dispatching
    include Helpers
    include Rendering

    attr_accessor :routes, :templates, :menus, :config

    def reset!
      @routes = []
      @templates = {}
      @menus = {}
      @config = {}

      register_defaults

      self
    end

    def host
      config[:host]
    end

    def port
      config[:port]
    end

    def run!
      return if ::EM.reactor_running?
      trap("INT") { exit }

      ::EM.run do
        @last_reload = Time.now

        puts "HOST #{config[:host]}"
        puts "PORT #{config[:port]}"
        puts "CONN #{Gopher::Connection.inspect}"

        ::EM.start_server(config[:host], config[:port], Gopher::Connection) do |c|
#          reload! if config[:reload]
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
