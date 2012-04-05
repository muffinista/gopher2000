ENV['gopher_test'] = "1"

require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

require 'bundler/setup'
Bundler.require

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}


require 'eventmachine'

#
# http://www.rosskaff.com/2010/12/behavior-driven-event-driven-eventmachine-rspec/
#
class FakeSocketClient < EventMachine::Connection

  attr_writer :onopen, :onclose, :onmessage
  attr_reader :data

  def initialize
    super

    @state = :new
    @data = []
  end

  def receive_data(data)
    #puts "RECV: #{data}"
    @data << data
    if @state == :new
      @onopen.call if @onopen
      @state = :open
    else
      @onmessage.call(data) if @onmessage
    end
  end

  def unbind
    @onclose.call if @onclose
  end
end


class FakeSocketServer < FakeSocketClient
  attr_accessor :application
end
