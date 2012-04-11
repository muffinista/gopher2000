require File.join(File.dirname(__FILE__), '..', 'gopher2000')

module Gopher
  #
  # very basic DSL to handle the common stuff you would want to do
  #
  module DSL

    include Logging

    @@application = nil
    def application
      return @@application unless @@application.nil?
      puts "fire up app"

      @@application = Gopher::Application #.new
      @@application.reset!
    end

    def set(key, value = nil)
      application.config[key] = value

      puts application.config.inspect
    end

    def route(path, &block)
      application.route(path, &block)
    end

    def mount(path, opts = {})
      route, folder = path.first

      #
      # if path has more than the one option (:route => :folder),
      # then incorporate the rest of the hash into our opts
      #
      if path.size > 1
        other_opts = path.dup
        other_opts.delete(route)
        opts = opts.merge(other_opts)
      end

      application.mount(route, opts.merge({:path => folder}))
    end

    def menu(name, &block)
      application.menu(name, &block)
    end
    def text(name, &block)
      application.text(name, &block)
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

    #
    # run a script with the specified options applied to the config. This is
    # called by bin/gopher2000
    #
    def run(script, opts = {})
      puts opts.inspect
      opts.each { |k, v|
        set k, v
      }

      if application.config[:debug] == true
        puts "watching #{script} for changes"
        watch script
      end

      load script
    end
  end
end

include Gopher::DSL
