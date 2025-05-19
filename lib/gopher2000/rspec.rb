# frozen_string_literal: true

require 'rspec/core'
require 'rspec/expectations'

module Gopher
  #
  # Matchers for integration specs
  #
  module RSpecMatchers
    def selectors_matching(expected, menu: client.menu)
      menu.select do |item|
        (expected[:type].nil? || (item[:type] == expected[:type])) &&
          (expected[:text].nil? || (item[:text] == expected[:text] || (expected[:text].is_a?(Regexp) && expected[:text].match?(item[:text])))) &&
          (expected[:selector].nil? || (item[:selector] == expected[:selector])) &&
          (expected[:host].nil? || (item[:host] == expected[:host])) &&
          (expected[:port].nil? || (item[:port] == expected[:port]))
      end
    end

    RSpec::Matchers.define :have_content do |expected|
      match do |actual|
        actual.response&.include?(expected)
      end

      failure_message do |actual|
        "expected output to contain #{expected}\n\n#{actual}"
      end
    end

    RSpec::Matchers.define :have_selector do |expected|
      match do |actual|
        selectors_matching(expected, menu: actual.menu).count == 1
      end

      failure_message do |actual|
        "expected menu to contain #{expected}\n\n#{actual.menu.join("\n")}"
      end
    end
  end
end

module Gopher
  #
  # Code to drive an integration spec
  #
  module TestDriver
    #
    # Start the gopher application, and wait for it to be running
    #
    def boot_application
      return @server if defined?(@server) && @server.status == :run

      @server = Gopher::Server.new(Gopher.application, host: @host, port: @port)
      @thread = @server.run!

      while @server.status != :run do; end
    end

    #
    # A client that can make gopher requests
    #
    def client
      @client ||= SimpleClient.new(@host, @port)
    end

    #
    # Send the specified payload to the gopher server
    #
    def request(payload, search: nil)
      boot_application

      @response = nil
      client.send search.nil? ? payload : [payload, search].join("\t")
    end

    # follow the given selector on the current page
    def follow(selector, search: nil)
      @response = nil

      selector = { text: selector } if selector.is_a?(String)
      sel = selectors_matching(selector).first

      @client = SimpleClient.new(@host, @port)
      payload = search.nil? ? sel[:selector] : [sel[:selector], search].join("\t")
      @client.send(payload)
    end

    #
    # read the response from the last request
    #
    def response
      return @response unless @response.nil?

      client.read
      @response = client
    end
  end
end

RSpec.configure do |config|
  config.include Gopher::RSpecMatchers, type: :integration
  config.include Gopher::TestDriver, type: :integration

  config.before do |_example|
    # @todo is this needed? also, is this ugly?
    Gopher._application = nil
  end

  config.around(:each, type: :integration) do |example|
    @host = ENV.fetch('host', '0.0.0.0')
    @port = ENV.fetch('port', 7071).to_i

    begin
      example.run
    ensure
      @server&.stop
      @thread&.join

      @server = nil
      @thread = nil
      @client = nil
    end
  end
end
