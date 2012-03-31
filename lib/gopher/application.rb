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

    #
    # check if our script has been updated since the last reload
    #
    def should_reload?
      ! @last_reload.nil? && self.scripts.any? do |f|
        File.mtime(f) > @last_reload
      end
    end

    #
    # reload scripts if needed
    #
    def reload_stale
      reload_check = should_reload?
      @last_reload = Time.now

      return if ! reload_check
      reset!

      self.scripts.each do |f|
        debug_log "reload #{f}"
        load f
      end
    end

    def reset!
      @routes = []
      @templates = {}
      @menus = {}
      @scripts ||= []

      register_defaults

      self
    end
  end
end
