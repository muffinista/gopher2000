require File.join(File.dirname(__FILE__), '/spec_helper')
require 'tempfile'

class FakeApp < Gopher::Application
  cattr_accessor :fake_response
  def dispatch(x)
    @@fake_response
  end
end

describe Gopher::Server do
  before(:each) do
    @application = FakeApp
    @application.reset!

    @host = "0.0.0.0"
    @port = 12345

    @application.config[:host] = @host
    @application.config[:port] = @port

    @request = Gopher::Request.new("foo", "bar")

    @response = Gopher::Response.new(@request)
    @response.code = :success
    @response.body = "hi"
  end

  it "should handle Gopher::Response results" do
#    @application.should_receive(:dispatch).with(any_args).and_return(@response)
#    @application.should_receive(:reload_stale)
    @application.fake_response = @response

    ::EM.run {
      server = Gopher::Server.new
      server.run!(@application)

      # opens the socket client connection
      socket = ::EM.connect(@host, @port, FakeSocketClient)
      socket.send_data("123\n")

      socket.onopen = lambda {
        socket.data.last.chomp.should == "hi\r\n."
        EM.stop
      }
    }
  end

  it "should handle string results" do
#    @application.should_receive(:dispatch).with(any_args).and_return(@response)
#    @application.should_receive(:reload_stale)
    @application.fake_response = @response

    ::EM.run {
      server = Gopher::Server.new
      server.run!(@application)

      # opens the socket client connection
      socket = ::EM.connect(@host, @port, FakeSocketClient)
      socket.send_data("123\n")

      socket.onopen = lambda {
        socket.data.last.chomp.should == "hi\r\n."
        EM.stop
      }
    }
  end

  it "should handle File results" do
    file = Tempfile.new('foo')
    file.write("hi")
    file.close

    @application.fake_response = File.new(file)

#    @application.should_receive(:dispatch).with(any_args).and_return(File.new(file))
#    @application.should_receive(:reload_stale)

    ::EM.run {
      server = Gopher::Server.new
      server.run!(@application)

      # opens the socket client connection
      socket = ::EM.connect(@host, @port, FakeSocketClient)
      socket.send_data("123\n")

      socket.onopen = lambda {
        socket.data.last.chomp.should == "hi"
        EM.stop
      }
    }
  end

  it "should handle StringIO results" do
    @application.fake_response = StringIO.new("hi")

    ::EM.run {
      server = Gopher::Server.new
      server.run!(@application)

      # opens the socket client connection
      socket = ::EM.connect(@host, @port, FakeSocketClient)
      socket.send_data("123\n")

      socket.onopen = lambda {
        socket.data.last.chomp.should == "hi\r\n."
        EM.stop
      }
    }
  end
end
