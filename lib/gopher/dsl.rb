module Gopher
  #
  # very basic DSL to handle the common stuff you would want to do with a bot.
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

    def route(path, *args, &block)
      application.route(path, args, &block)
    end

    def menu(name, &block)
      application.menu(name, &block)
    end

    def template(name, &block)
      application.template(name, &block)
    end

    def helpers(&block)
      puts "define some helpers"
      application.helpers(&block)
    end
  end
end

