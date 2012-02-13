require File.join(File.dirname(__FILE__), '/spec_helper')

class MockServer
  attr_accessor :menus
  include Gopher::Rendering

  def initialize
    @menus = {}
  end
end


describe Gopher::Rendering do
  describe "find_template" do
    it "should check in menus" do
      @s = MockServer.new
      @s.menus['foo'] = "bar"

      @s.find_template('foo').should == "bar"
    end
  end

  describe "render" do

  end
end
