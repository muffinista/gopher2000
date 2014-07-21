require File.join(File.dirname(__FILE__), '/spec_helper')

class MockApplication < Gopher::Application
  attr_accessor :menus, :routes, :config, :scripts, :last_reload

  def initialize
    @routes = []
    @menus = {}
    @scripts ||= []
    @config = {}

    register_defaults
  end
end

describe Gopher::Application do
  before(:each) do
    @server = MockApplication.new
  end

  describe "lookup" do
    it "should work with simple route" do
      @server.route '/about' do; end
      @request = Gopher::Request.new("/about")

      keys, block = @server.lookup(@request.selector)
      expect(keys).to eq({})
    end

    it "should translate path" do
      @server.route '/about/:foo/:bar' do;  end
      @request = Gopher::Request.new("/about/x/y")

      keys, block = @server.lookup(@request.selector)
      expect(keys).to eq({:foo => 'x', :bar => 'y'})
    end

    it "should return default route if no other route found, and default is defined" do
      @server.default_route do
        "DEFAULT ROUTE"
      end
      @request = Gopher::Request.new("/about/x/y")
      @response = @server.dispatch(@request)
      expect(@response.body).to eq("DEFAULT ROUTE")
      expect(@response.code).to eq(:success)
    end

    it "should respond with error if no route found" do
      @server.route '/about/:foo/:bar' do;  end
      @request = Gopher::Request.new("/junk/x/y")

      @response = @server.dispatch(@request)
      expect(@response.code).to eq(:missing)
    end

    it "should respond with error if invalid request" do
      @server.route '/about/:foo/:bar' do;  end
      @request = Gopher::Request.new("x" * 256)

      @response = @server.dispatch(@request)
      expect(@response.code).to eq(:error)
    end

    it "should respond with error if there's an exception" do
      @server.route '/x' do; raise Exception; end
      @request = Gopher::Request.new("/x")

      @response = @server.dispatch(@request)
      expect(@response.code).to eq(:error)
    end
  end

  describe "dispatch" do
    before(:each) do
      #@server.should_receive(:lookup).and_return({})
      @server.route '/about' do
        'GOPHERTRON'
      end

      @request = Gopher::Request.new("/about")
    end

    it "should run the block" do
      @response = @server.dispatch(@request)
      expect(@response.body).to eq("GOPHERTRON")
    end
  end

  describe "dispatch, with params" do
    before(:each) do
      @server.route '/about/:x/:y' do
        params.to_a.join("/")
      end

      @request = Gopher::Request.new("/about/a/b")
    end

    it "should use incoming params" do
      @response = @server.dispatch(@request)
      expect(@response.body).to eq("x/a/y/b")
    end
  end

  describe "dispatch to mount" do
    before(:each) do
      @h = double(Gopher::Handlers::DirectoryHandler)
      expect(@h).to receive(:application=).with(@server)
      expect(Gopher::Handlers::DirectoryHandler).to receive(:new).with({:bar => :baz, :mount_point => "/foo"}).and_return(@h)

      @server.mount "/foo", :bar => :baz
    end

    it "should work for root path" do
      @request = Gopher::Request.new("/foo")
      expect(@h).to receive(:call).with({:splat => ""}, @request)

      @response = @server.dispatch(@request)
      expect(@response.code).to eq(:success)
    end

    it "should work for subdir" do
      @request = Gopher::Request.new("/foo/bar")
      expect(@h).to receive(:call).with({:splat => "bar"}, @request)

      @response = @server.dispatch(@request)
      expect(@response.code).to eq(:success)
    end
  end


  describe "globs" do
    before(:each) do
      @server.route '/about/*' do
        params[:splat]
      end
    end

    it "should put wildcard into param[:splat]" do
      @request = Gopher::Request.new("/about/a/b")
      @response = @server.dispatch(@request)
      expect(@response.body).to eq("a/b")
    end
  end
end
