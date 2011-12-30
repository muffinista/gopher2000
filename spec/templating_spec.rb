require File.join(File.dirname(__FILE__), '/spec_helper')

class MockServer
  attr_accessor :templates, :menus
  include Gopher::Templating
end

describe Gopher::Templating do
  before(:all) do
    @klass = MockServer.new
  end

  it 'should store templates' do
    @klass.menu :index do
      "foo"
    end

    @klass.menus.should include(:index)
  end

  it 'should find templates' do
    @klass.template :index do
      "foo"
    end
    @klass.templates.should include(:index)
  end
end
