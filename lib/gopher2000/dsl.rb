# frozen_string_literal: true

require File.join(File.dirname(__FILE__), '..', 'gopher2000')

module Gopher
  #
  # DSL that can be used to specify gopher apps with a very simple format.
  # @see the examples/ directory for working scripts
  #
  module DSL
    #
    # initialize an instance of an Application if we haven't already, otherwise, return
    #   the current app
    # @return [Gopher::Application] current app
    #
    def application
      return Gopher._application unless Gopher._application.nil?

      Gopher._application = Gopher::Application.new
      Gopher._application.reset!
    end

    def application=(app)
      if app.is_a?(Gopher::Application)
        # @todo properly test this
        Gopher._application = app
      else
        load app
      end
    end

    # set a config value
    # @param [Symbol] key key to add to config
    # @param [String] value value to set
    def set(key, value = nil)
      application.config[key] = value
    end

    # specify a route
    # @param [String] path path of the route
    # @yield block that will respond to the request
    def route(path, &)
      application.route(path, &)
    end

    # specify a default route
    def default_route(&)
      application.default_route(&)
    end

    # mount a folder for browsing
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

      application.mount(route, opts.merge({ path: folder }))
    end

    # specify a menu template
    # @param [Symbol] name of the template
    # @yield block which renders the template
    def menu(name, &)
      application.menu(name, &)
    end

    # specify a text template
    # @param [Symbol] name of the template
    # @yield block which renders the template
    def text(name, &)
      application.text(name, &)
    end

    #    def template(name, &block)
    #      application.template(name, &block)
    #    end

    # specify some helpers for your app
    # @yield block which defines the helper methods
    def helpers(&)
      application.helpers(&)
    end

    # watch the specified script for changes
    # @param [String] f script to watch
    def watch(f)
      application.scripts << f
    end

    #
    # run a script with the specified options applied to the config. This is
    #   called by bin/gopher2000
    # @param [String] script path to script to run
    # @param [Hash] opts options to pass to script. these will override any
    #   config options specified in the script, so you can use this to
    #   run on a different host/port, etc.
    #
    def run(script, opts = {})
      load script

      #
      # apply options after loading the script so that anything specified on the command-line
      # will take precedence over defaults specified in the script
      #
      opts.each do |k, v|
        set k, v
      end

      return unless application.config[:debug] == true

      puts "watching #{script} for changes"
      watch script
    end
  end
end

include Gopher::DSL

#
# don't call at_exit if we're running specs
#
unless ENV['gopher_test']
  at_exit do
    s = Gopher::Server.new(Gopher._application)
    s.run!(background: false)
  end
end
