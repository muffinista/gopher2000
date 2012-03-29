require File.join(File.dirname(__FILE__), '..', 'gopher')

module Gopher
  #
  # very basic DSL to handle the common stuff you would want to do
  #
  module DSL

    include Logging

    def application
      return @application unless @application.nil?
      @application = Gopher::Application.new
      @application.reset!
    end

    def set(key, value = nil)
      debug_log "SET #{key} #{value}"
      application.config[key] = value
    end

    def route(path, &block)
      application.route(path, &block)
    end

    def mount(path, opts = {})
      route, folder = path.first
      application.mount(route, opts.merge({:path => folder}))
    end

    def menu(name, &block)
      application.menu(name, &block)
    end

    def template(name, &block)
      application.template(name, &block)
    end

    def helpers(&block)
      application.helpers(&block)
    end

    def watch(f)
      application.scripts << f
    end

    def run(script, opts = {})
      opts.each { |k, v|
        set k, v
      }

      if application.config[:debug] == true
        debug_log "watching #{script} for changes"
        watch script
      end

      load script
    end

  end
end

include Gopher::DSL
