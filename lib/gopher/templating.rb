module Gopher
  module Templating
    # Defines the dsl for creating new templates
    # All templates defined here are added to +klass+#templates
    class TemplateContext
      attr_accessor :klass

      def initialize(klass, &block)
        @klass = klass
        instance_eval(&block)
      end

      # Define a menu template. The contents of this template will be rendered in a MenuContext
      def menu(name, &block)
        context = Gopher::Rendering::MenuContext
        @klass.templates[name] = block, context
      end

      # Define a new basic text template
      def template(name, &block)
        context = Gopher::Rendering::TextContext
        @klass.templates[name] = block, context
      end

      # Define a partial template. Gets run in the same context it is called in
      def partial(name, &block)
        @klass.partials[name] = block
      end
    end

    # Search the local "template space" for a match
    # If nothing is found, move on to the global templates
    def find_template(template)
      local = templates[template]
      local || find_global_template(template)
    end

    # Search the local "partials space" for a match
    # Does not move on to the global space (no global partials)
    def find_partial(partial)
      partial = partials[partial]
      partial || @host.find_partial(partial)
    end

    # Search the server's global templates for a match
    def find_global_template(template)
      global = Gopher::Server.templates[template]
      global || raise(TemplateNotFound)
    end

    # A hash of all templates registered to this gophlet
    # +block+ is evaluated in a TemplateContext to create new templates
    def templates(&block)
      @templates ||= {}
      block_given? ? TemplateContext.new(self, &block) : @templates
    end

    # All partials registered to this gophlet
    def partials
      @partials ||= {}
    end

    # Add a shortcut to the class finder to instances of +klass+
    def self.extended(klass)
      klass.class_eval { def find_template(t); self.class.find_template(t); end }
      klass.class_eval { def find_partial(p); self.class.find_partial(p); end }
    end
  end
end
