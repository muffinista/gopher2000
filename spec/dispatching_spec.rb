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
      @server.route '/about' do
        'mr. gopher loves you'
      end
      @request = Gopher::Request.new("/about")

      keys, block = @server.lookup(@request.selector)
      keys.should == {}

#      block.call(@server).should == "mr. gopher loves you"
    end

    it "should translate path" do
      @server.route '/about/:foo/:bar' do
        "#{params[:foo]} #{params[:bar]}"
      end
      @request = Gopher::Request.new("/about/x/y")

      keys, block = @server.lookup(@request.selector)
      keys.should == {:foo => 'x', :bar => 'y'}

 #     block.call(@server).should == "x y"
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
      #puts @response.body
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

  pending "globs"
end
