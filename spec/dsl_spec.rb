require File.join(File.dirname(__FILE__), '/spec_helper')

class FakeServer

end

describe Gopher::DSL do
  before(:each) do
    @app = Gopher::Application.new

    @server = FakeServer.new
    @server.send :require, 'gopher/dsl'
    @server.stub!(:application).and_return(@app)
    @app.reset!
  end


  describe "set" do
    it "should set a config var" do
      @server.set :foo, 'bar'
      @app.config[:foo].should == 'bar'
    end
  end

  describe "route" do
    it "should pass a lookup and block to the app" do
      @app.should_receive(:route).with('/foo')
      @server.route '/foo' do
        "hi"
      end
    end

    pending "test block?"
  end

  describe "menu" do
    it "should pass a menu key and block to the app" do
      @app.should_receive(:menu).with('/foo')
      @server.menu '/foo' do
        "hi"
      end
    end
  end

  describe "template" do
    it "should pass a template key and block to the app" do
      @app.should_receive(:template).with('/foo')
      @server.template '/foo' do
        "hi"
      end
    end
  end

  describe "helpers" do
    it "should pass a block to the app" do
      @app.should_receive(:helpers)
      @server.helpers do
        "hi"
      end
    end
  end

end
