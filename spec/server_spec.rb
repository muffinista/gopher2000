require File.join(File.dirname(__FILE__), '/spec_helper')
require 'tempfile'

if ENV["WITH_SERVER_SPECS"].to_i == 1

  class FakeApp < Gopher::Application
    attr_accessor :fake_response
    def dispatch(x)
      @fake_response
    end
  end

  describe Gopher::Server do
    before(:each) do
      @application = FakeApp.new
      @application.scripts = []
      @application.reset!

      @host = "0.0.0.0"
      @port = 12345
      @environment = 'test'

      @application.config[:host] = @host
      @application.config[:port] = @port
      @application.config[:env] = @environment

      @request = Gopher::Request.new("foo", "bar")

      @response = Gopher::Response.new
      @response.code = :success
      @response.body = "hi"
    end

    it "returns host" do
      @application.config[:host] = 'gopher-site.test'
      expect(@application.host).to eql('gopher-site.test')
    end

    it "returns port" do
      expect(@application.port).to eql(@port)
    end

    it "returns environment" do
      expect(@application.env).to eql(@environment)
    end
   
    
    it "should work in non-blocking mode" do
      @application.fake_response = @response
      allow(@application).to receive(:non_blocking?).and_return(false)

      ::EM.run {
        server = Gopher::Server.new(@application)
        server.run!

        # opens the socket client connection
        socket = ::EM.connect(@host, @port, FakeSocketClient)
        socket.send_data("123\n")

        socket.onopen = lambda {
          expect(socket.data.last.chomp).to eq("hi\r\n.")
          EM.stop
        }
      }
    end

    it "should handle Gopher::Response results" do
      @application.fake_response = @response

      ::EM.run {
        server = Gopher::Server.new(@application)
        server.run!

        # opens the socket client connection
        socket = ::EM.connect(@host, @port, FakeSocketClient)
        socket.send_data("123\n")

        socket.onopen = lambda {
          expect(socket.data.last.chomp).to eq("hi\r\n.")
          EM.stop
        }
      }
    end

    it "should handle string results" do
      @application.fake_response = @response

      ::EM.run {
        server = Gopher::Server.new(@application)
        server.run!

        # opens the socket client connection
        socket = ::EM.connect(@host, @port, FakeSocketClient)
        socket.send_data("123\n")

        socket.onopen = lambda {
          expect(socket.data.last.chomp).to eq("hi\r\n.")
          EM.stop
        }
      }
    end

    it "should handle File results" do
      file = Tempfile.new('foo')
      file.write("hi")
      file.close

      @application.fake_response = File.new(file)

      ::EM.run {
        server = Gopher::Server.new(@application)
        server.run!

        # opens the socket client connection
        socket = ::EM.connect(@host, @port, FakeSocketClient)
        socket.send_data("123\n")

        socket.onopen = lambda {
          expect(socket.data.last.chomp).to eq("hi")
          EM.stop
        }
      }
    end

    it "should handle StringIO results" do
      @application.fake_response = StringIO.new("hi")

      ::EM.run {
        server = Gopher::Server.new(@application)
        server.run!

        # opens the socket client connection
        socket = ::EM.connect(@host, @port, FakeSocketClient)
        socket.send_data("123\n")

        socket.onopen = lambda {
          expect(socket.data.last.chomp).to eq("hi\r\n.")
          EM.stop
        }
      }
    end
  end
end
