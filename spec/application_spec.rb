require File.join(File.dirname(__FILE__), '/spec_helper')
require 'tempfile'

describe Gopher::Application do
  before(:each) do
    @app = Gopher::Application.new
    @app.reset!
    @app.scripts = []
  end

  it 'should have default host/port' do
    expect(@app.host).to eq("0.0.0.0")
    expect(@app.port).to eq(70)
  end

  describe "should_reload?" do
    it "is false if no scripts" do
      expect(@app.should_reload?).to eq(false)
    end

    it "shouldn't do anything if last_reload not set" do
      expect(@app.last_reload).to be_nil
      @app.scripts << "foo.rb"
      expect(@app.should_reload?).to eq(false)
    end

    it "should check script date" do
      now = Time.now
      allow(Time).to receive(:now).and_return(now)

      @app.last_reload = Time.now - 1000
      @app.scripts << "foo.rb"
      expect(File).to receive(:mtime).with("foo.rb").and_return(now)

      expect(@app.should_reload?).to eq(true)
    end
  end

  describe "reload_stale" do
    it "should load script and update last_reload" do
      now = Time.now
      allow(Time).to receive(:now).and_return(now)

      expect(@app).to receive(:should_reload?).and_return(true)

      @app.last_reload = Time.now - 1000
      @app.scripts << "foo.rb"
      expect(@app).to receive(:load).with("foo.rb")
      @app.reload_stale

      expect(@app.last_reload).to eq(now)
    end
  end
end
