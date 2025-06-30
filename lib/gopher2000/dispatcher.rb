# frozen_string_literal: true

require 'socket'
require 'pry'

module Gopher
  #
  # Handle communication between Server and the actual gopher Application
  #
  class Dispatcher
    # the Application we are running
    attr_accessor :app

    def initialize(app, socket)
      @app = app
      @socket = socket
    end

    def logger
      @app.logger
    end
    
    #
    # get the IP address of the client
    # @return ip address
    #
    def remote_ip
      @socket&.peeraddr&.last
    end

    def read!
      incoming = if @app.non_blocking?
                   begin
                     @socket.read_nonblock(4096)
                   rescue Errno::EAGAIN
                     logger.debug "EAGAIN on read"
                     IO.select([@socket])
                     
                     retry
                   end
                 else
                   @socket.readpartial(4096)
                 end
      receive_data(incoming)
    end

    #
    # called with the raw data of an incoming request
    #
    # @param [String] data raw data, should be a selector
    # @return Response object
    #
    def receive_data(data)
      if data.length > 1000
        logger.warn "Input too long, exiting!"
        return
      end

      logger.debug "==== receive_data"
      @buf = [@buf, data].compact.join
      first_line = true

      ip_address = remote_ip
      while (line = @buf.slice!(/(.*)\r?\n/))
        # logger.debug line
        is_proxy = first_line && line.match?(/^PROXY TCP[4,6] /)

        receive_line(line, ip_address) unless is_proxy
        ip_address = line.split(/ /)[2] if is_proxy

        first_line = false
      end
    end

    # Invoked with lines received over the network
    def receive_line(line, ip_address)
      logger.debug "Handle request: #{line} #{ip_address}"
      call! Request.new(line, ip_address)
    end

    #
    # generate a request object from an incoming selector, and dispatch it to the app
    # @param [Request] request Request object to handle
    # @return Response object
    #
    def call!(request)
      result = app.dispatch(request)
      send_response result
    end

    #
    # send the response back to the client
    # @param [Response] response object
    #
    def send_response(response)
      case response
      when Gopher::Response then send_response(response.body)
      when String then send_data(response + end_of_transmission)
      when StringIO then send_data(response.read + end_of_transmission)
      when File
        while (chunk = response.read(8192))
          send_data(chunk)
        end
        response.close
      end
    end

    # @todo handle blocking?
    def send_data(payload)
      logger.debug "Write data back to socket"
      if @app.non_blocking?
        size = payload.size
        begin
          loop do
            bytes = @socket.write_nonblock(payload)
            logger.debug "Wrote #{bytes} bytes"
            break if bytes >= size
            payload.slice!(0, bytes)
            IO.select(nil, [client])
          end
        rescue Errno::EAGAIN
          logger.debug "EAGAIN on write"
          IO.select(nil, [client])
          retry
        end
      else
        @socket.write(payload)
      end
    end

    #
    # Add the period on a line by itself that closes the connection
    #
    # @return valid string to mark end of transmission as specified in RFC1436
    def end_of_transmission
      [Gopher::Rendering::LINE_ENDING, '.', Gopher::Rendering::LINE_ENDING].join
    end
  end
end
