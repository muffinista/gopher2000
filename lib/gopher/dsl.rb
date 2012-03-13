require File.join(File.dirname(__FILE__), '..', 'gopher')

module Gopher
  #
  # very basic DSL to handle the common stuff you would want to do
  #
  module DSL
    def application
      return @application unless @application.nil?

      @application = Gopher::Application.new
      @application.reset!
    end

    def set(key, value = nil)
      puts "SET #{key} #{value}"
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

    def watch(f)
      application.scripts << f
    end

    def run(script, opts = {})
      opts.each { |k, v|
        set k, v
      }

      if application.config[:debug] == true
        puts "you should watch #{script}"
        watch script
      end

      load script
    end

  end
end

include Gopher::DSL
