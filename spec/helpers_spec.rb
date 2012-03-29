require File.join(File.dirname(__FILE__), '/spec_helper')

describe Gopher::Helpers do
  before(:each) do
    @obj = Object.new
    @obj.extend(Gopher::Helpers)
  end

  it 'should add code to target class' do
    @obj.helpers(Object) do
      def foo; "FOO"; end
    end

    @obj.foo.should == "FOO"
  end
end
