module Gopher
  class Dispatcher < EventMachine::Connection

    attr_accessor :app

    #
    # get the IP address of the client
    #
    def remote_ip
      Socket.unpack_sockaddr_in(get_peername).last
    end


    #
    # called by EventMachine when there's an incoming request
    # roughly matching sinatra's style of duping the app to respond
    # to requests, @see http://www.sinatrarb.com/intro#Request/Instance%20Scope
    #
    # this essentially means we have 'one instance per request'
    #
    def receive_data(selector)
      dup.call!(selector)
    end

    def call!(selector)
      # parse out the request
      @request = Request.new(selector, remote_ip)

      operation = proc {
        resp = app.dispatch(@request)
        resp
      }
      callback = proc {|result|
        send_response result
        close_connection_after_writing
      }

      #
      # if we don't want to block on slow calls, use EM#defer
      # @see http://eventmachine.rubyforge.org/EventMachine.html#M000486
      #
      if app.non_blocking?
        EventMachine.defer( operation, callback )
      else
        callback.call(operation.call)
      end
    end

    #
    # send the response back to the client
    #
    def send_response(response)
      case response
      when Gopher::Response then send_response(response.body)
      when String then send_data(response + end_of_transmission)
      when StringIO then send_data(response.read + end_of_transmission)
      when File
        while chunk = response.read(8192) do
          send_data(chunk)
        end
        response.close
      end
    end

    #
    # Add the period on a line by itself that closes the connection
    #
    # @todo don't add an extra line ending here if we don't need it
    def end_of_transmission
      [Gopher::Rendering::LINE_ENDING, ".", Gopher::Rendering::LINE_ENDING].join
    end

  end
end
