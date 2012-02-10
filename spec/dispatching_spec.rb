require File.join(File.dirname(__FILE__), '/spec_helper')

class MockServer
  attr_accessor :routes
  include Gopher::Routing
  include Gopher::Dispatching
end


describe Gopher::Dispatching do
  before(:each) do
    @server = MockServer.new
  end

  describe "lookup" do
    it "should work with simple route" do
      @server.route '/about' do; end
      @request = Gopher::Request.new("/about")

      keys, block = @server.lookup(@request.selector)
      keys.should == {}
    end

    it "should translate path" do
      @server.route '/about/:foo/:bar' do;  end
      @request = Gopher::Request.new("/about/x/y")

      keys, block = @server.lookup(@request.selector)
      keys.should == {:foo => 'x', :bar => 'y'}
    end

    it "should return default route if no other route found, and default is defined" do
      @server.default_route do
        "DEFAULT ROUTE"
      end
      @request = Gopher::Request.new("/about/x/y")
      @response = @server.dispatch(@request)
      @response.body.should == "DEFAULT ROUTE"
    end

    pending "should throw error if no route found" do

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
      @response.body.should == "GOPHERTRON"
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
      @response.body.should == "x/a/y/b"
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
      @response.body.should == "a/b"
    end
  end
end
