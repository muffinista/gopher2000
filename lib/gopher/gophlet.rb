module Gopher
  # A basic gophlet.
  #
  # You can subclass this to get some behaviour for free in your own stand-alone gophlets,
  # such as helpers, templates, rendering and...uh...
  class Gophlet
    attr_accessor :base
    
    def self.expected_arguments
      config[:moo] || /.*/
    end

    extend Templating
    extend Configuration
    extend Helpers
    extend Routing

    include Dispatching
    include Rendering

    def initialize(base='/')
      @base = base
    end
  end

  # Inline gophlets are instances of InlineGophlet
  class InlineGophlet < Gophlet
    attr_accessor :host, :block, :input

    def initialize(host, &block)
      @block = block
      @host = host
    end

    def with(host, input)
      @host, @input = host, input.to_s.strip; self
    end

    def call(*arguments)
      self.instance_exec(*arguments, &block)
    end

    def find_template(template); host.find_template(template) end
    def find_partial(partial); host.find_partial(partial) end
  end
end
