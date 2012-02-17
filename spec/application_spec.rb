require File.join(File.dirname(__FILE__), '/spec_helper')

describe Gopher::Application do
  it 'should have default host/port' do
    a = Gopher::Application.new
    a.host.should == "0.0.0.0"
    a.port.should == 70
  end
end
