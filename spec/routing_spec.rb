require File.join(File.dirname(__FILE__), '/spec_helper')

class MockServer
  attr_accessor :routes
  include Gopher::Routing
end

describe Gopher::Routing do
  before(:all) do
    @klass = MockServer.new
  end


  pending "should work with text output" do
    @klass.route '/about' do; end
  end

  pending "should work with input" do
    @klass.route '/name' do
      render :hello, input.strip
    end
  end

  pending "should work with templates" do
    @klass.route '/' do
      render :index
    end
  end
end
