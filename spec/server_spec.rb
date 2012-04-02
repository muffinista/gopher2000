require File.join(File.dirname(__FILE__), '/spec_helper')
require 'tempfile'

describe Gopher::Server do
  before(:each) do
    @host = "0.0.0.0"
    @port = 12345
    @application = mock(Gopher::Application, :config => {:host => @host, :port => @port})

    @request = Gopher::Request.new("foo", "bar")

    @response = Gopher::Response.new(@request)
    @response.code = :success
    @response.body = "hi"
  end

  it "should handle Gopher::Response results" do
    @application.should_receive(:dispatch).with(any_args).and_return(@response)
    @application.should_receive(:reload_stale)

    ::EM.run {
      server = Gopher::Server.new(@application)
      server.run!

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
    @application.should_receive(:dispatch).with(any_args).and_return(@response)
    @application.should_receive(:reload_stale)

    ::EM.run {
      server = Gopher::Server.new(@application)
      server.run!

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

    @application.should_receive(:dispatch).with(any_args).and_return(File.new(file))
    @application.should_receive(:reload_stale)

    ::EM.run {
      server = Gopher::Server.new(@application)
      server.run!

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
    @application.should_receive(:dispatch).with(any_args).and_return(StringIO.new("hi"))
    @application.should_receive(:reload_stale)

    ::EM.run {
      server = Gopher::Server.new(@application)
      server.run!

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
