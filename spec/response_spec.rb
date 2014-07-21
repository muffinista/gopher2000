require File.join(File.dirname(__FILE__), '/spec_helper')
require 'tempfile'

describe Gopher::Response do
  before(:each) do
    @response = Gopher::Response.new
  end

  it "gets size for string results" do
    @response.body = "hi"
    expect(@response.size).to eq(2)
  end

  it "gets size for stringio results" do
    @response.body = StringIO.new("12345")
    expect(@response.size).to eq(5)
  end

  it "defaults to 0 size for weird objects" do
    @response.body = double(Object)
    expect(@response.size).to eq(0)
  end


  it "gets size for file results" do
    temp_file = Tempfile.new('result')
    temp_file.write("1234567890")
    temp_file.flush

    @response.body = File.new(temp_file.path)
    expect(@response.size).to eq(10)
  end
end
