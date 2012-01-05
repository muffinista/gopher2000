require File.join(File.dirname(__FILE__), '/spec_helper')

describe Gopher::Handler do
  before(:each) do
    @handler = Gopher::Handler.new("/foo", "ip_address")
    @request = Gopher::Request.new("/foo")                            
    @handler.should_receive(:request).with.and_return(@request)
  end

  it 'should call dispatch with request' do
    application.should_receive(:dispatch).with(@request)
    @handler.handle
  end

  it 'pass back result of dispatch' do
    application.should_receive(:dispatch).with(@request).and_return("foo")
    @handler.handle.should == "foo"
  end
end