require File.join(File.dirname(__FILE__), '/spec_helper')

describe Gopher::Application do
  it 'should have default host/port' do
    a = Gopher::Application.new
    a.host.should == "0.0.0.0"
    a.port.should == 70
  end

  describe "reload_stale" do
    before(:each) do
      @app = Gopher::Application.new
    end

    it "should be ok if no scripts" do
      @app.reload_stale
    end


    it "shouldn't do anything if last_reload not set" do
      @app.last_reload.should be_nil
      @app.scripts << "foo.rb"
      File.should_not_receive(:mtime).with("foo.rb")
      @app.reload_stale
    end

    it "should check script date" do
      now = Time.now
      Time.stub!(:now).and_return(now)

      @app.last_reload = Time.now - 1000
      @app.scripts << "foo.rb"
      File.should_receive(:mtime).with("foo.rb").and_return(now)

      @app.should_receive(:load).with("foo.rb")
      @app.reload_stale

      @app.last_reload.should == now
    end

  end
end
