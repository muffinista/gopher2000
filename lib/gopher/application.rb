module Gopher
  class Application

    include Routing
    include Dispatching
    include Helpers
    include Rendering

    attr_accessor :templates, :menus, :routes, :config, :scripts

    def initialize(c={})
      @config = {
        :host => '0.0.0.0',
        :port => 70
      }.merge(c)

      #
      # don't run this code if we're running specs
      #
      unless ENV['gopher_test']
        at_exit do
          s = Gopher::Server.new(self, self.host, self.port)
          s.run!
        end
      end

      reset!
    end

    def host
      config[:host]
    end

    def port
      config[:port]
    end

    def reset!
      @routes = []
      @templates = {}
      @menus = {}
      @scripts = []

      register_defaults

      self
    end
  end
end
