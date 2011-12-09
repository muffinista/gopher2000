require File.join(File.dirname(__FILE__), '/spec_helper')

describe Gopher::Utils do
  it 'should sanitize selectors' do
    raw = '//.../...heyho'
    sane = Gopher::Utils.sanitize_selector(raw)
    sane.should == '/./.heyho'
  end

  it 'should determine gopher types from filenames' do
    Gopher::Utils.determine_type("hey.jpg").should == 'I'
    Gopher::Utils.determine_type("hey.PNG").should == 'I'
    Gopher::Utils.determine_type("hey.wav").should == 's'
    Gopher::Utils.determine_type("hey.lulz").should == '0'
  end
end
