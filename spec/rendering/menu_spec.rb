require File.join(File.dirname(__FILE__), '/../spec_helper')

describe Gopher::Rendering::Menu do
  before(:each) do
    @ctx = Gopher::Rendering::Menu.new
  end

  it 'should add text as a gopher line' do
    @ctx.text("gopher forever")

    # note that there's no line ending here because Base#<< will add that
    @ctx.result.should == "igopher forever\tnull\t(FALSE)\t0"
  end

  pending "sanitize"
  
  pending "line"
  pending "link"
  pending "search"
  pending "menu"
  pending "determine_type"
end
