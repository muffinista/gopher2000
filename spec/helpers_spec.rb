require File.join(File.dirname(__FILE__), '/spec_helper')

describe Gopher::Helpers do
  before(:all) do
    obj = Object.new
    obj.extend(Gopher::Helpers)

    obj.helpers do
      def foo; end
    end
  end

  it 'should add code to RenderContext' do
    Gopher::Rendering::RenderContext.public_instance_methods.should include('foo')
  end
end
