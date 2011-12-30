module Gopher
  class Connection
    def receive_data(selector)
      port, ip = Socket.unpack_sockaddr_in(get_peername)
      puts "got #{data.inspect} from #{ip}:#{port}"

      begin
        request = Request.new(selector, ip)
        send_response application.dispatch(request)

      rescue Gopher::NotFound => e
        Gopher.logger.error "Unknown selector. #{e}"
      rescue Gopher::InvalidRequest => e
        Gopher.logger.error "Invalid request. #{e}"
      rescue => e
        Gopher.logger.error "Bad juju afoot. #{e}"; puts e
        raise e
      ensure
        close_connection_after_writing
      end
    end

    def send_response(response)
      case response
      when String then send_data(response)
      when StringIO then send_data(response.read)
      when File
        while chunk = response.read(8192) do
          send_data(chunk)
        end
      end
    end
  end
end
