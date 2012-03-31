require File.join(File.dirname(__FILE__), '/spec_helper')

describe Gopher::Application do
  before(:each) do
    @app = Gopher::Application.new
  end

  it 'should have default host/port' do
    @app = Gopher::Application.new
    @app.host.should == "0.0.0.0"
    @app.port.should == 70
  end

  describe "should_reload?" do
    it "is false if no scripts" do
      @app.should_reload?.should == false
    end

    it "shouldn't do anything if last_reload not set" do
      @app.last_reload.should be_nil
      @app.scripts << "foo.rb"
      @app.should_reload?.should == false
    end

    it "should check script date" do
      now = Time.now
      Time.stub!(:now).and_return(now)

      @app.last_reload = Time.now - 1000
      @app.scripts << "foo.rb"
      File.should_receive(:mtime).with("foo.rb").and_return(now)

      @app.should_reload?.should == true
    end
  end

  describe "reload_stale" do
    it "should load script and update last_reload" do
      now = Time.now
      Time.stub!(:now).and_return(now)

      @app.should_receive(:should_reload?).and_return(true)

      @app.last_reload = Time.now - 1000
      @app.scripts << "foo.rb"
      @app.should_receive(:load).with("foo.rb")
      @app.reload_stale

      @app.last_reload.should == now
    end

  end
end
