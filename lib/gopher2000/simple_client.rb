# frozen_string_literal: true

require 'socket'

#
# This is a very simple Gopher client, it just opens
# up a socket and sends the command. It has some simple
# parsing for menus/etc
#
class SimpleClient
  attr_reader :response

  def initialize(host, port)
    raise StandardError, 'no host!' if host.nil?
    raise StandardError, 'no port!' if port.nil?

    @socket = TCPSocket.new(host, port)
  end

  def send(data)
    # ensure we send a newline
    data = "#{data}\n" unless data.match?(/\n$/)
    @socket.write(data)
  end

  def read
    @response = @socket.read(nil)
  end

  def close
    @socket.close
  end

  def lines
    @response.split("\r\n")
  end

  def menu
    lines.map do |l|
      type_and_text, selector, host, port = l.split("\t")

      if type_and_text
        type = type_and_text[0]
        text = type_and_text[1..]
      else
        type = nil
        text = nil
      end

      {
        type: type,
        text: text,
        selector: selector,
        host: host,
        port: port
      }
    end
  end

  def to_s
    @response.nil? ? super : @response
  end
end
