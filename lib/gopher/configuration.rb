module Gopher
  module Configuration
    def config(&block)
      @configuration ||= {}
      block_given? ? ConfigContext.new(self, &block) : @configuration
    end

    # Neat idea from merb!
    class ConfigContext # nodoc
      def initialize(klass, &block) #:nodoc:
        @klass = klass
        instance_eval(&block)
      end

      def method_missing(method, *args) #:nodoc:
        #@klass.config[method] = *args
        @klass.config[method] = args.first
      end
    end
  end
end
