require File.join(File.dirname(__FILE__), '/spec_helper')

describe Gopher::Handler do
  pending "#handle" do
    before(:each) do
      @handler = Gopher::Handler.new("/foo", "ip_address")
      @request = Gopher::Request.new("/foo")
      @handler.should_receive(:request).and_return(@request)
    end

    it 'should call dispatch with request' do
      application.should_receive(:dispatch).with(@request)
      @handler.handle
    end

    it 'pass back result of dispatch' do
      application.should_receive(:dispatch).with(@request).and_return("foo")
      @handler.handle.should == "foo"
    end

    it "should raise uncaught exceptions" do
      application.should_receive(:dispatch).with(@request).and_raise(Exception)
      @handler.handle.should == "Sorry, there was an error"
    end
  end

  pending "#request" do
    before(:each) do
      @handler = Gopher::Handler.new("/foo", "ip_address")
    end

    it "should generate a new request with the proper attrs" do
      @handler.request.selector.should == "/foo"
      @handler.request.ip_address.should == "ip_address"
    end
  end
end
