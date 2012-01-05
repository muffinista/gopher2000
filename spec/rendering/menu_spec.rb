describe Gopher::Rendering::Menu do
  before(:all) do
    @ctx = Gopher::Rendering::Menu.new
  end

  it 'should add text as a gopher line' do
    @ctx.text("tortilla")
    @ctx.result.should == "itortilla\tnull\t(FALSE)\t0\r\n"
  end
end
