module Gopher
  class Application

    include Routing
    include Dispatching
    include Helpers
    include Rendering

    attr_accessor :templates, :menus, :routes, :config

    def initialize(c={})
      @config = {
        :host => '0.0.0.0',
        :port => 70
      }.merge(c)
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

      register_defaults

      self
    end
  end
end
