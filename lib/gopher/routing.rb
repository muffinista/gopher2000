module Gopher
  module Routing

    #
    # define a route
    #
    def route(path, &block)
      selector = self.sanitize_selector(path)
      sig = compile!(selector, &block)

      @routes ||= []
      @routes << sig
    end

    def default_route(&block)
      # make sure we initialize the routes array

      @default_route = Dispatching.generate_method("DEFAULT_ROUTE", &block)
    end

    def compile!(path, &block)
      method_name = path
      route_method = Dispatching.generate_method(method_name, &block)
      pattern, keys = compile path


      # sinatra does some arity checks when making routes -- not sure we need them

      #      [ pattern, keys, conditions, block.arity != 0 ?
      #        proc { |a,p| puts "A: #{a}, P: #{p}"; route_method.bind(a).call(*p) } :
      #        proc { |a,p| route_method.bind(a).call } ]

      [ pattern, keys, route_method ]
    end

    protected
    def compile(path)
      keys = []
#      if path.respond_to? :to_str
        pattern = path.to_str.gsub(/[^\?\%\\\/\:\*\w]/) { |c| encoded(c) }
        pattern.gsub!(/((:\w+)|\*)/) do |match|
          if match == "*"
            keys << 'splat'
            "(.*?)"
          else
            keys << $2[1..-1]
            "([^/?#]+)"
          end
        end
        [/^#{pattern}$/, keys]
      # elsif path.respond_to?(:keys) && path.respond_to?(:match)
      #   [path, path.keys]
      # elsif path.respond_to?(:names) && path.respond_to?(:match)
      #   [path, path.names]
      # elsif path.respond_to? :match
      #   [path, keys]
#      else
#        raise TypeError, path
#      end
    end

    # Sanitizes a gopher selector
    def sanitize_selector(raw)
      selector = raw.to_s.dup
      selector.strip! # Strip whitespace
      selector.sub!(/\/$/, '') # Strip last rslash
      selector.sub!(/^\/*/, '/') # Strip extra lslashes
      selector.gsub!(/\.+/, '.') # Don't want consecutive dots!
      selector
    end
  end
end
