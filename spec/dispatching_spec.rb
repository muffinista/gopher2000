require File.join(File.dirname(__FILE__), '/spec_helper')

class MockServer
  attr_accessor :routes
  include Gopher::Routing
  include Gopher::Dispatching
  include Gopher::Templating
  include Gopher::Rendering

  def initialize
    @menus = {}
  end
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
      @response.code.should == :success
    end

    it "should respond with error if no route found" do
      @server.route '/about/:foo/:bar' do;  end
      @request = Gopher::Request.new("/junk/x/y")

      @response = @server.dispatch(@request)
      @response.code.should == :missing
    end

    pending "should respond with error if invalid request" do
      @server.route '/about/:foo/:bar' do;  end
      @request = Gopher::Request.new("x" * 256)

      @response = @server.dispatch(@request)
      @response.code.should == :error
    end
  end


    # describe "not found" do
    #   it "should raise not found error" do
    #     @handler.should_receive(:handle_not_found)
    #     expect{application.dispatch(@request)}.to raise_error(Gopher::NotFoundError)
    #     @handler.handle
    #   end
    # end

    # describe "error" do
    #   it "should raise invalid request" do
    #     @handler.should_receive(:handle_invalid_request)

    #     @request.selector =
    #     expect{application.dispatch(@request)}.to raise_error(Gopher::InvalidRequest)

    #     @handler.handle
    #   end
    # end


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

  describe "dispatch to mount" do
    before(:each) do
      @h = mock(Gopher::Handlers::DirectoryHandler)
      Gopher::Handlers::DirectoryHandler.should_receive(:new).with({:bar => :baz}).and_return(@h)

      @server.mount "/foo", :bar => :baz
    end

    it "should work for root path" do
      @h.should_receive(:call).with(:splat => "")

      @request = Gopher::Request.new("/foo")
      @response = @server.dispatch(@request)
    end

    it "should work for subdir" do
      @h.should_receive(:call).with(:splat => "bar")

      @request = Gopher::Request.new("/foo/bar")
      @response = @server.dispatch(@request)
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
