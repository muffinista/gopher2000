module Gopher
  module Connection
    def receive_data(selector)
      begin
        raise InvalidRequest, "Message too long" if selector.length >= 255

        Gopher.logger.info "Dispatching to #{selector}"

        response = Gopher::Server.dispatch(selector)

        case response
        when String then send_data(response)
        when StringIO then send_data(response.read)
        when File
          while chunk = response.read(8192) do
            send_data(chunk)
          end
        end
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
  end
end
