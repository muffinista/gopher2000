require File.join(File.dirname(__FILE__), '/spec_helper')

class FakeApp < Gopher::Application

end

class FakeServer < Gopher::Server

end

describe Gopher::DSL do
  before(:each) do
    @app = FakeApp.new

    @server = FakeServer.new(@app)
    @server.send :require, 'gopher2000/dsl'
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
  end

  describe "default_route" do
    it "should pass a default block to the app" do
      @app.should_receive(:default_route)
      @server.default_route do
        "hi"
      end
    end
  end

  describe "mount" do
    it "should pass a route, path, and some opts to the app" do
      @app.should_receive(:mount).with('/foo', {:path => "/bar"})
      @server.mount "/foo" => "/bar"
    end

    it "should pass a route, path, filter, and some opts to the app" do
      @app.should_receive(:mount).with('/foo', {:path => "/bar", :filter => "*.jpg"})
      @server.mount "/foo" => "/bar", :filter => "*.jpg"
    end
  end

  describe "menu" do
    it "should pass a menu key and block to the app" do
      @app.should_receive(:menu).with('/foo')
      @server.menu '/foo' do
        "hi"
      end
    end
  end

  describe "text" do
    it "should pass a text_template key and block to the app" do
      @app.should_receive(:text).with('/foo')
      @server.text '/foo' do
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

  describe "watch" do
    it "should pass a script app for watching" do
      @app.scripts.should_receive(:<<).with("foo")
      @server.watch("foo")
    end
  end

  describe "run" do
    it "should set any incoming opts" do
      @server.should_receive(:set).with(:x, 1)
      @server.should_receive(:set).with(:y, 2)
      @server.stub!(:load)

      @server.run("foo", {:x => 1, :y => 2})
    end

    it "should turn on script watching if in debug mode" do
      @app.config[:debug] = true
      @server.should_receive(:watch).with("foo.rb")
      @server.should_receive(:load).with("foo.rb")

      @server.run("foo.rb")
    end

    it "should load the script" do
      @server.should_receive(:load).with("foo.rb")
      @server.run("foo.rb")
    end
  end

end
