module Gopher
  #
  # very basic DSL to handle the common stuff you would want to do
  #
  module DSL
    def self.included(mod)
      @@application = nil
    end

    def application
      return @@application unless @@application.nil?

      @@application = Gopher::Application.new
      @@application.reset!
    end

    def set(key, value = nil)
      application.config[key] = value
    end

    def route(path, &block)
      application.route(path, &block)
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

    #
    # don't run this code if we're running specs
    #
    unless ENV['gopher_test']
      at_exit do
        unless application.nil?
          s = Gopher::Server.new(application, application.host, application.port)
          s.run!
        end
      end
    end
  end

end
