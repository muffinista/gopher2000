module Gopher
  module Routing

    attr_accessor :routes

    #
    # mount '/files' => '/home/colin/foo', :filter => '*.jpg'
    #
    def mount(path, opts = {}, klass = Gopher::Handlers::DirectoryHandler)
      handler = klass.new(opts)
      route(globify(path)) do
        handler.call(params)
      end
    end

    #
    # add a glob to the end of this string, if there's not one already
    #
    def globify(p)
      p =~ /\*/ ? p : "#{p}/?*".gsub("//", "/")
    end

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

      [ pattern, keys, route_method ]
    end

    #
    # lookup an incoming path
    #
    def lookup(selector)
      unless @routes.nil?
        @routes.each do |pattern, keys, block|

          if match = pattern.match(selector)
            match = match.to_a
            url = match.shift

            params = to_params_hash(keys, match)

            @params = params
            return params, block
          end
        end
      end

      unless @default_route.nil?
        return {}, @default_route
      end

      raise Gopher::NotFoundError
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
