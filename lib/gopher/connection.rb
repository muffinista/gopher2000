module Gopher
  class Connection < EventMachine::Connection
    def receive_data(selector)
      ip = remote_ip
      puts "got #{selector} from #{ip}"

      begin
        handler = Handler.new
        send_response handler.handle(selector, ip)
      ensure
        close_connection_after_writing
      end
    end

    def remote_ip
      #      port, ip =
      Socket.unpack_sockaddr_in(get_peername).last
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
