module Gopher
  module Dispatching

    attr_accessor :params

    def lookup(selector)
      routes.each do |pattern, keys, block|
        if match = pattern.match(selector)
          match = match.to_a
          url = match.shift

          params = to_params_hash(keys, match)

          @params = params
          return params, block
        end
      end
    end

    #
    # find and run routes which match the incoming request
    #
    def dispatch(request)
      @params, block = lookup(request.selector)
      @response = Response.new

      # call the block that handles this lookup
      @response.body = block.bind(self).call

      @response
    end

    #
    # zip up two arrays of keys and values from an incoming request
    #
    def to_params_hash(keys,values)
      hash = {}
      keys.size.times { |i| hash[ keys[i].to_sym ] = values[i] }
      hash
    end


    class << self
      def generate_method(method_name, &block)
        define_method(method_name, &block)
        method = instance_method method_name
        remove_method method_name
        method
      end
    end
  end
end
