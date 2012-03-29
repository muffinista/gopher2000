module Gopher
  class Application

    include Routing
    include Dispatching
    include Helpers
    include Rendering
    include Logging

    attr_accessor :templates, :menus, :routes, :config, :scripts, :last_reload

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

    def reload_stale
      self.scripts.each do |f|
        if ! @last_reload.nil? && File.mtime(f) > @last_reload
          debug_log "reload #{f}"
          load f
        end
      end
      @last_reload = Time.now
    end

    def reset!
      @last_reload = nil

      @routes = []
      @templates = {}
      @menus = {}
      @scripts = []

      register_defaults

      self
    end
  end
end
