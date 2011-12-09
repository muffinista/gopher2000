module Gopher
  class Server
    extend Configuration
    extend Routing
    extend Templating # mmm
    extend Dispatching
    extend Helpers

    def self.host; config[:host] || '0.0.0.0' end # Shortcut for getting the server host
    def self.port; config[:port] || 70 end # Shortcut for getting the server port

    def self.reload!
      if config[:reload].class == String
        config[:reload] = [ config[:reload] ]
      end


      config[:reload].each do |f|
        load f if File.mtime(f) > @last_reload
        @last_reload = Time.now
      end
    end

    def self.run
      return if ::EM.reactor_running?
      trap("INT") { exit }

      ::EM.run do
        @last_reload = Time.now
        ::EM.start_server(host, port, Gopher::Connection) do |c|
          reload! if config[:reload]
        end
      end
    end
  end
end
