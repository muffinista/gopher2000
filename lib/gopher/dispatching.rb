module Gopher
  module Dispatching

    attr_accessor :params

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

    def lookup(selector)
      routes.each do |pattern, keys, conditions, block|
        if match = pattern.match(selector)
          #puts "**** #{keys} #{conditions}"
          match = match.to_a
          url = match.shift
          #puts "MATCH #{match.inspect}"

          params = to_params_hash(keys, match)

          #puts "PARAMS #{params.inspect}"

          @params = params
          return params, conditions, block
        end
      end
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
