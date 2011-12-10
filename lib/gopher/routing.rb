module Gopher
  #
  # The routing module. Sanitizes selectors, routes requests and does awesome shit
#
  module Routing
    def route(path, *args, &block)
      selector = Gopher::Utils.sanitize_selector(path)

      # @todo toss *args or do something with it
      sig = compile!(selector, block, {})

      puts sig.inspect

      @routes << sig
    end

    class << self
      def generate_method(method_name, &block)
        define_method(method_name, &block)
        method = instance_method method_name
        remove_method method_name
        method
      end
    end

    private
    def compile_route(path)
      keys = []
      if path.respond_to? :to_str
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
      end
    end

    def compile!(path, block, options = {})
      options.each_pair { |option, args| send(option, *args) }
      method_name             = path
      unbound_method          = Routing.generate_method(method_name, &block)
      pattern, keys           = compile path
      conditions, @conditions = @conditions, []

      [ pattern, keys, conditions, block.arity != 0 ?
        proc { |a,p| unbound_method.bind(a).call(*p) } :
        proc { |a,p| unbound_method.bind(a).call } ]
    end

    def compile(path)
      keys = []
      if path.respond_to? :to_str
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
      elsif path.respond_to?(:keys) && path.respond_to?(:match)
        [path, path.keys]
      elsif path.respond_to?(:names) && path.respond_to?(:match)
        [path, path.names]
      elsif path.respond_to? :match
        [path, keys]
      else
        raise TypeError, path
      end
    end

  end
end
