# frozen_string_literal: true

ENV['gopher_test'] = '1'

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/examples/'
end

require 'bundler/setup'
Bundler.require

require_relative '../lib/gopher2000/simple_client'
require_relative '../lib/gopher2000/rspec'

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
