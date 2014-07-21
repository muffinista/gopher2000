require File.join(File.dirname(__FILE__), '/spec_helper')

describe Gopher::Request do
  it 'should split raw request' do
    request = Gopher::Request.new("foo\tbar")
    expect(request.selector).to eq("/foo")
    expect(request.input).to eq("bar")
  end

  it "normalizes by adding a slash to the front" do
    request = Gopher::Request.new("foo")
    expect(request.selector).to eq("/foo")
  end

  it "should be ok with just selector" do
    request = Gopher::Request.new("/foo")
    expect(request.selector).to eq("/foo")
    expect(request.input).to eq(nil)
  end

  it "should accept ip_address" do
    request = Gopher::Request.new("foo", "bar")
    expect(request.ip_address).to eq("bar")
  end

  it "valid? == true for valid selectors" do
    request = Gopher::Request.new("x" * 254, "bar")
    expect(request.valid?).to eq(true)
  end

  it "valid? == false for invalid selectors" do
    request = Gopher::Request.new("x" * 255, "bar")
    expect(request.valid?).to eq(false)
  end
end
