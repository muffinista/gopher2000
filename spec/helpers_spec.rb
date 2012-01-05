require File.join(File.dirname(__FILE__), '/spec_helper')

describe Gopher::Helpers do
  before(:each) do
    obj = Object.new
    obj.extend(Gopher::Helpers)

    obj.helpers do
      def foo; "FOO"; end
    end
  end

  it 'should add code to Rendering::Base' do
    h = Gopher::Rendering::Base.new
    h.foo.should == "FOO"
  end
end
