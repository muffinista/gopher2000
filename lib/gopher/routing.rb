module Gopher
  module Routing

    def route(path, *args, &block)
      selector = self.sanitize_selector(path)

      # @todo toss *args or do something with it
      sig = compile!(selector, block, {})

      #puts sig.inspect

      @routes ||= []
      @routes << sig
    end

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
      unbound_method          = Dispatching.generate_method(method_name, &block)
     # unbound_method          = generate_method(method_name, &block)
      pattern, keys           = compile path

#      [ pattern, keys, conditions, block.arity != 0 ?
#        proc { |a,p| puts "A: #{a}, P: #{p}"; unbound_method.bind(a).call(*p) } :
#        proc { |a,p| unbound_method.bind(a).call } ]

      [ pattern, keys, unbound_method ]
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
