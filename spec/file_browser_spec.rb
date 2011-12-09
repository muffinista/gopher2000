require File.join(File.dirname(__FILE__), '/spec_helper')

describe Gopher::FileBrowser do
  before(:all) do
    path = File.join(File.dirname(__FILE__), 'sandbox')
    @gophlet = Gopher::FileBrowser.new('/files', path)
  end

  it 'should dispatch to files' do
    @gophlet.dispatch('/socks.txt').should be_instance_of(File)
  end

  it 'should do directory listings' do
    str = "1old\t/files/old\t0.0.0.0\t70\r\n0socks.txt\t/files/socks.txt\t0.0.0.0\t70\r\ni---\tnull\t(FALSE)\t0\r\n"
    @gophlet.dispatch('/').should == str
  end

  it 'should do directory listings' do
    str = "0socks.txt\t/files/socks.txt\t0.0.0.0\t70\r\ni---\tnull\t(FALSE)\t0\r\n"
    @gophlet.dispatch('/old').should == str
  end
end
