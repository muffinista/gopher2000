module Gopher
  class Application

    include Routing
    include Dispatching
    include Templating
    include Helpers

    attr_accessor :routes, :templates, :menus, :config

    def reset!
      @routes = []
      @templates = {}
      @menus = {}
      @config = {}

      self
    end

    if ARGV.any?
      require 'optparse'
      OptionParser.new { |op|
        op.on('-p port',   'set the port (default is 4567)')                { |val| set :port, Integer(val) }
        op.on('-o addr',   'set the host (default is 0.0.0.0)')             { |val| set :bind, val }
        op.on('-e env',    'set the environment (default is development)')  { |val| set :environment, val.to_sym }
      }.parse!(ARGV.dup)
    end
  end
end
