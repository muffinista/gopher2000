# frozen_string_literal: true

ENV['gopher_test'] = '1'

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/examples/'
end

require 'bundler/setup'
Bundler.require

require "#{File.dirname(__FILE__)}/../lib/gopher2000/rspec.rb"

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

#
# http://www.rosskaff.com/2010/12/behavior-driven-event-driven-eventmachine-rspec/
#
class FakeSocketClient
  attr_writer :onopen, :onclose, :onmessage
  attr_reader :data

  def initialize
    super

    @state = :new
    @data = []
  end

  def receive_data(data)
    # puts "RECV: #{data}"
    @data << data
    if @state == :new
      @onopen&.call
      @state = :open
    elsif @onmessage
      @onmessage&.call(data)
    end
  end

  def unbind
    @onclose&.call
  end
end

class FakeSocketServer < FakeSocketClient
  attr_accessor :application
end

class SimpleClient
  attr_reader :response

  def initialize(host, port)
    raise StandardError, 'no host!' if host.nil?
    raise StandardError, 'no port!' if port.nil?

    @socket = TCPSocket.open(host, port)
  end

  def send(data)
    @socket.puts(data)
  end

  def read
    @response = @socket.gets(nil)
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
