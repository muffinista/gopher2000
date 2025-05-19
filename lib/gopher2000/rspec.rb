# frozen_string_literal: true

require 'rspec/core'
require 'rspec/expectations'

def selectors_matching(expected, menu: client.menu)
  menu.select do |item|
    (expected[:type].nil? || (item[:type] == expected[:type])) &&
      (expected[:text].nil? || (item[:text] == expected[:text])) &&
      (expected[:selector].nil? || (item[:selector] == expected[:selector])) &&
      (expected[:host].nil? || (item[:host] == expected[:host])) &&
      (expected[:port].nil? || (item[:port] == expected[:port]))
  end
end

RSpec::Matchers.define :have_content do |expected|
  match do |actual|
    actual.response.include?(expected)
  end
end

RSpec::Matchers.define :have_selector do |expected|
  match do |actual|
    selectors_matching(expected, menu: actual.menu).count == 1
  end
end

RSpec.configure do |config|
  # config.include Capybara::DSL, type: :feature
  # config.include Gopher::RSpecMatchers, type: :feature

  # The before and after blocks must run instantaneously, because Capybara
  # might not actually be used in all examples where it's included.
  config.after do
    # if self.class.include?(Capybara::DSL)
    #   Capybara.reset_sessions!
    #   Capybara.use_default_driver
    # end
  end

  config.before do |_example|
    Gopher._application = nil

    # if self.class.include?(Capybara::DSL)
    #   Capybara.current_driver = Capybara.javascript_driver if example.metadata[:js]
    #   Capybara.current_driver = example.metadata[:driver] if example.metadata[:driver]
    # end
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

  def boot_application
    return @server if defined?(@server) && @server.status == :run

    @server = Gopher::Server.new(Gopher.application, host: @host, port: @port)
    @thread = @server.run!

    while @server.status != :run do; end
  end

  def client
    @client ||= SimpleClient.new(@host, @port)
  end

  def request(payload)
    boot_application
    client.send payload
  end

  def follow(selector)
    selector = { text: selector } if selector.is_a?(String)
    sel = selectors_matching(selector).first

    #    @client = SimpleClient.new(sel[:host], sel[:port])
    @client = SimpleClient.new(@host, @port)
    @client.send(sel[:selector])
  end

  def response
    client.read
    client
  end
end
