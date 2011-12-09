require File.join(File.dirname(__FILE__), '/spec_helper')

describe Gopher::Rendering::RenderContext do
  before(:all) do
    @ctx = Gopher::Rendering::RenderContext.new
  end

  it 'should add text' do
    @ctx.text("cake")
    @ctx.text("oh yes")
    @ctx.result.should == "cakeoh yes"
  end
end

describe Gopher::Rendering::MenuContext do
  before(:all) do
    @ctx = Gopher::Rendering::MenuContext.new
  end

  it 'should add text as a gopher line' do
    @ctx.text("tortilla")
    @ctx.result.should == "itortilla\tnull\t(FALSE)\t0\r\n"
  end
end
