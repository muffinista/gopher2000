require File.join(File.dirname(__FILE__), '/spec_helper')

class MockServer
  attr_accessor :routes
  include Gopher::Routing
end

describe Gopher::Routing do
  before(:all) do
    @klass = MockServer.new
  end

  pending "test something real"

  it "should work with text output" do
    @klass.route '/about' do
      'mr. gopher loves you'
    end
  end

  it "should work with input" do
    @klass.route '/name' do
      render :hello, input.strip
    end
  end

  it "should work with templates" do
    @klass.route '/' do
      render :index
    end
  end
end
