require File.join(File.dirname(__FILE__), '/spec_helper')
require 'tempfile'

class SimpleClient
  def initialize(host, port)
    @socket = TCPSocket.open(host, port)
  end
  
  def send(data)
    @socket.puts(data)
  end
  
  def read
    @socket.gets(nil)
  end

  def close
    @socket.close
  end
end


class FakeApp < Gopher::Application
  attr_accessor :fake_response
  def dispatch(x)
    @fake_response
  end
end

def start_server
  @server = Gopher::Server.new(@application)
  @thread = @server.run!
  
  while @server.status != :run do; end
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

  after do
    @server&.stop
    @thread&.join
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

    start_server

    client = SimpleClient.new(@host, @port)
    client.send("123\n")

    expect(client.read).to eq("hi\r\n.\r\n")
  end

  it "should handle Gopher::Response results" do
    @application.fake_response = @response

    start_server

    client = SimpleClient.new(@host, @port)
    client.send("123\n")

    expect(client.read).to eq("hi\r\n.\r\n")
  end

  it "should handle string results" do
    @application.fake_response = @response

    start_server

    client = SimpleClient.new(@host, @port)
    client.send("123\n")

    expect(client.read).to eq("hi\r\n.\r\n")
  end

  it "should handle File results" do
    file = Tempfile.new('foo')
    file.write("hi")
    file.close

    @application.fake_response = File.new(file)

    start_server

    client = SimpleClient.new(@host, @port)
    client.send("123\n")

    expect(client.read).to eq("hi")
  end

  it "should handle StringIO results" do
    @application.fake_response = StringIO.new("hi")

    start_server

    client = SimpleClient.new(@host, @port)
    client.send("123\n")

    expect(client.read).to eq("hi\r\n.\r\n")
  end
end
