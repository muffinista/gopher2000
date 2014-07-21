require File.join(File.dirname(__FILE__), '/spec_helper')

describe Gopher::Application do
  before(:each) do
    @obj = Gopher::Application.new
#    @obj.extend(Gopher::Helpers)
  end

  it 'should add code to target class' do
    @obj.helpers do
      def foo; "FOO"; end
    end

    expect(@obj.foo).to eq("FOO")
  end
end
