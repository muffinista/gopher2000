require File.join(File.dirname(__FILE__), '/spec_helper')
require 'tempfile'

describe Gopher::Server do
  before(:each) do
    @host = "0.0.0.0"
    @port = 12345
    @application = mock(Gopher::Application)
  end

  it "should handle Gopher::Response results" do
    @response = Gopher::Response.new
    @response.body = "hi"
    @response.code = :success
    @application.should_receive(:dispatch).with(any_args).and_return(@response)


    ::EM.run {
      server = Gopher::Server.new(@application, @host, @port)
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
    @application.should_receive(:dispatch).with(any_args).and_return("hi")


    ::EM.run {
      server = Gopher::Server.new(@application, @host, @port)
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

    ::EM.run {
      server = Gopher::Server.new(@application, @host, @port)
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

    ::EM.run {
      server = Gopher::Server.new(@application, @host, @port)
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
