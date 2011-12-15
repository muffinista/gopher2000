require File.join(File.dirname(__FILE__), '/spec_helper')

describe Gopher::Request do
  it 'should split raw request' do
    request = Gopher::Request.new("foo\tbar")
    request.selector.should == "foo"
    request.input.should == "bar"
  end

  it "should be ok with just selector" do
    request = Gopher::Request.new("foo")
    request.selector.should == "foo"
    request.input.should == nil
  end

  it "should accept ip_address" do
    request = Gopher::Request.new("foo", "bar")
    request.ip_address.should == "bar"
  end
end
