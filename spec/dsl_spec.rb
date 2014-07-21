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
    allow(@server).to receive(:application).and_return(@app)
    @app.reset!
  end


  describe "set" do
    it "should set a config var" do
      @server.set :foo, 'bar'
      expect(@app.config[:foo]).to eq('bar')
    end
  end

  describe "route" do
    it "should pass a lookup and block to the app" do
      expect(@app).to receive(:route).with('/foo')
      @server.route '/foo' do
        "hi"
      end
    end
  end

  describe "default_route" do
    it "should pass a default block to the app" do
      expect(@app).to receive(:default_route)
      @server.default_route do
        "hi"
      end
    end
  end

  describe "mount" do
    it "should pass a route, path, and some opts to the app" do
      expect(@app).to receive(:mount).with('/foo', {:path => "/bar"})
      @server.mount "/foo" => "/bar"
    end

    it "should pass a route, path, filter, and some opts to the app" do
      expect(@app).to receive(:mount).with('/foo', {:path => "/bar", :filter => "*.jpg"})
      @server.mount "/foo" => "/bar", :filter => "*.jpg"
    end
  end

  describe "menu" do
    it "should pass a menu key and block to the app" do
      expect(@app).to receive(:menu).with('/foo')
      @server.menu '/foo' do
        "hi"
      end
    end
  end

  describe "text" do
    it "should pass a text_template key and block to the app" do
      expect(@app).to receive(:text).with('/foo')
      @server.text '/foo' do
        "hi"
      end
    end
  end

  describe "helpers" do
    it "should pass a block to the app" do
      expect(@app).to receive(:helpers)
      @server.helpers do
        "hi"
      end
    end
  end

  describe "watch" do
    it "should pass a script app for watching" do
      expect(@app.scripts).to receive(:<<).with("foo")
      @server.watch("foo")
    end
  end

  describe "run" do
    it "should set any incoming opts" do
      expect(@server).to receive(:set).with(:x, 1)
      expect(@server).to receive(:set).with(:y, 2)
      allow(@server).to receive(:load)

      @server.run("foo", {:x => 1, :y => 2})
    end

    it "should turn on script watching if in debug mode" do
      @app.config[:debug] = true
      expect(@server).to receive(:watch).with("foo.rb")
      expect(@server).to receive(:load).with("foo.rb")

      @server.run("foo.rb")
    end

    it "should load the script" do
      expect(@server).to receive(:load).with("foo.rb")
      @server.run("foo.rb")
    end
  end

end
