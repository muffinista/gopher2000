module Gopher
  module Dispatching

    attr_accessor :params, :request

    #
    # find and run routes which match the incoming request
    #
    def dispatch(req)
      debug_log(req)

      response = Response.new
      @request = req

      if ! @request.valid?
        debug_log("sorry, request wasn't valid")
        response.body = handle_invalid_request
        response.code = :error
        return response
      end


      begin
        debug_log("do lookup for #{@request.selector}")
        @params, block = lookup(@request.selector)

        #
        # call the block that handles this lookup
        #
        response.body = block.bind(self).call
        response.code = :success

      rescue Gopher::NotFoundError => e
        debug_log("#{@request.selector} -- not found")
        response.body = handle_not_found
        response.code = :missing
      rescue Exception => e
        debug_log("#{@request.selector} -- error")
        debug_log(e.inspect)
        debug_log(e.backtrace)

        response.body = handle_error(e)
        response.code = :error
      end
      response
    end


    #
    # zip up two arrays of keys and values from an incoming request
    #
    def to_params_hash(keys,values)
      hash = {}
      keys.size.times { |i| hash[ keys[i].to_sym ] = values[i] }
      hash
    end

    def handle_not_found
      render not_found_template
    end

    def handle_error(e)
      render error_template, e
    end

    def handle_invalid_request
      render invalid_request_template
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
