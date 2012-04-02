require 'socket'
module Gopher
  class Connection < EventMachine::Connection
    attr_accessor :application

    def receive_data(selector)
      # parse out the request
      @request = Request.new(selector, remote_ip)

      # route/run it
      resp = @application.dispatch(@request)

      # log it
      @application.access_log(@request, resp)

      # send it back!
      send_response resp
    ensure
      close_connection_after_writing
    end

    def remote_ip
      Socket.unpack_sockaddr_in(get_peername).last
    end

    #
    # @todo work on end_of_transmission call
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

    protected
    #
    # Add the period on a line by itself that closes the connection
    #
    # @todo don't add an extra line ending here if we don't need it
    def end_of_transmission
      [Gopher::Rendering::LINE_ENDING, ".", Gopher::Rendering::LINE_ENDING].join
    end
  end
end
