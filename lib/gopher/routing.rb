module Gopher
  # The routing module. Sanitizes selectors, routes requests and does awesome shit
  module Routing
    # Add a shortcut to the route map to instances of +klass+
    def self.extended(klass)
      klass.class_eval { def router; self.class.router.with(self); end }
    end

    # The route map for this server / gophlet
    def router
      @router ||= RouteMap.new(self)
    end

    # Define the routes for this server / gophlet
    def routing(&block)
      router.instance_eval(&block)
    end

    # The route map itself
    class RouteMap # nodoc
      attr_accessor :routes, :owner

      # Route +selector+ to +gophlet+ or define behaviour inline through +block+
      def route(raw, gophlet = nil, *args, &block)
        selector = Gopher::Utils.sanitize_selector(raw)

        if gophlet # Route to an gophlet
puts gophlet.expected_arguments
          matcher = %r{^\/?#{selector}(\/?#{gophlet.expected_arguments})$}
puts matcher.inspect
          routes[matcher] = gophlet.new(raw, *args)
        elsif block_given? # Create an InlineGophlet for this route
          matcher = %r{^\/?#{selector}$}
          routes[matcher] = InlineGophlet.new(owner, &block)
        else
          raise ArgumentError.new('Route to an gophlet or define behaviour inline through a block')
        end
      end

      def initialize(gophlet) # nodoc
        @owner = gophlet
        @routes = {}
      end

      def with(gophlet) # nodoc
        @owner = gophlet; self
      end

      # Grab the gophlet tied to +selector+ in the route map
      def lookup(raw)
        selector = Gopher::Utils.sanitize_selector(raw)
        routes.find do |k, v|
          return v, *$~[1..-1] if k=~ selector
        end
        raise NotFound
      end
    end
  end
end
