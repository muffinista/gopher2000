require File.join(File.dirname(__FILE__), '/spec_helper')
require 'tempfile'

describe Gopher::Response do
  before(:each) do
    @response = Gopher::Response.new
  end

  it "gets size for string results" do
    @response.body = "hi"
    @response.size.should == 2
  end

  it "gets size for stringio results" do
    @response.body = StringIO.new("12345")
    @response.size.should == 5
  end

  it "gets size for file results" do
    temp_file = Tempfile.new('result')
    temp_file.write("1234567890")
    temp_file.flush

    @response.body = File.new(temp_file.path)
    @response.size.should == 10
  end
end
