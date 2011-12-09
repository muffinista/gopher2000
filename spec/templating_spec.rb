require File.join(File.dirname(__FILE__), '/spec_helper')

describe Gopher::Templating do
  before(:all) do
    @klass = Class.new
    @klass.extend(Gopher::Templating)

    @klass.templates do
      menu :index do
        "foo"
      end
    end
    @obj = @klass.new
  end

  it 'should store templates' do
    @klass.templates.should include(:index)
  end  

  it 'should find templates' do
    @obj.find_template(:index).should_not be_empty
  end  
end
