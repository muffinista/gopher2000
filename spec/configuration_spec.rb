require File.join(File.dirname(__FILE__), '/spec_helper')

describe Gopher::Configuration do
  before(:all) do
    @app = Object.new
    @app.extend(Gopher::Configuration)
  end

  it 'should start out empty' do
    @app.config.should be_empty
  end

  it 'should let us do configuration through a block' do
    @app.config { title 'a title' }
    @app.config[:title].should == 'a title'
  end

  it 'should not confuse separate configurations' do
    obj = Object.new
    obj.extend(Gopher::Configuration)
    obj.config.should be_empty
  end
end
