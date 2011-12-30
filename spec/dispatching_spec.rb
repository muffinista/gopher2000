require File.join(File.dirname(__FILE__), '/spec_helper')

class MockServer
  attr_accessor :routes
  include Gopher::Routing
  include Gopher::Dispatching
end


describe Gopher::Dispatching do
  before(:all) do
    @server = MockServer.new
  end

  describe "lookup" do
    it "should work with simple route" do
      @server.route '/about' do
        'mr. gopher loves you'
      end
      @request = Gopher::Request.new("/about")

      keys, conditions, block = @server.lookup(@request.selector)
      keys.should == {}

#      block.call(@server).should == "mr. gopher loves you"
    end

    it "should translate path" do
      @server.route '/about/:foo/:bar' do
        "#{params[:foo]} #{params[:bar]}"
      end
      @request = Gopher::Request.new("/about/x/y")

      keys, conditions, block = @server.lookup(@request.selector)
      keys.should == {:foo => 'x', :bar => 'y'}

 #     block.call(@server).should == "x y"
    end
  end

  describe "dispatch" do
    before(:each) do
      #@server.should_receive(:lookup).and_return({})
      @server.route '/about' do
        puts "WTFFFFFFFF #{params}"
        'mr. gopher loves you'
      end

      @request = Gopher::Request.new("/about")
    end

    it "should run the block" do
      @response = @server.dispatch(@request)
      puts @response.body
    end

  end
end
