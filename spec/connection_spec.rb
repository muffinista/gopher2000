require File.join(File.dirname(__FILE__), '/spec_helper')

describe Gopher::Connection do
  before(:each) do
    @host = "0.0.0.0"
    @port = 12345
  end

  pending "missing requests should work" do
    ::EM.run {
      app = Gopher::Application.new(@host, @port)
      app.run!

      # opens the socket client connection
      socket = ::EM.connect(@host, @port, FakeSocketClient)
      socket.send_data("foo\n")

      socket.onopen = lambda {
        socket.data.last.chomp.should == "iSorry, foo was not found\tnull\t(FALSE)\t0\r\n."
        EM.stop
      }
    }
  end

  pending "string returns should work" do
    ::EM.run {
      app = Gopher::Application.new(@host, @port)
      app.run!

      app.route '/foo' do
        "hi"
      end


      # opens the socket client connection
      socket = ::EM.connect(@host, @port, FakeSocketClient)
      socket.send_data("/foo")

      socket.onopen = lambda {
        socket.data.last.chomp.should == "hi"
        EM.stop
      }
    }
  end

  pending "returning strings"
  pending "returning stringio"
  pending "returning files"
end
