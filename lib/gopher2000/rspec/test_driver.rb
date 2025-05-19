# frozen_string_literal: true

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

      # force menu load
      client.menu

      selector = { text: selector } if selector.is_a?(String)
      sel = selectors_matching(selector).first

      @response = nil
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
