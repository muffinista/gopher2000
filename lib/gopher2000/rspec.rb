# frozen_string_literal: true

require 'rspec/core'
require 'rspec/expectations'

require_relative 'rspec/matchers'
require_relative 'rspec/test_driver'

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
