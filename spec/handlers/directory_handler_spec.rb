require File.join(File.dirname(__FILE__), '..', '/spec_helper')

describe Gopher::Handlers::DirectoryHandler do
  before(:each) do
    @h = Gopher::Handlers::DirectoryHandler.new(:path => "/tmp")
  end

  describe "request_path" do
    it "should join existing path with incoming path" do
      @h.request_path(:splat => "bar/baz").should == "/tmp/bar/baz"
    end

    pending "sanitize"
  end

  describe "directories" do
    before(:each) do
      File.should_receive(:directory?).with("/tmp/bar/baz").and_return(true)
      Dir.should_receive(:glob).with("/tmp/bar/baz/*.*").and_return(["/tmp/bar/baz/a"])
    end

    pending "application/host"

    it "should work" do
      @h.call(:splat => "bar/baz").to_s.should == "0a\t/tmp/bar/baz/a\t\t"
    end
  end

  describe "files" do
    before(:each) do
      @file = mock(File)
      File.should_receive(:directory?).with("/tmp/baz.txt").and_return(false)
      File.should_receive(:file?).with("/tmp/baz.txt").and_return(true)
      File.should_receive(:new).with("/tmp/baz.txt").and_return(@file)
    end

    it "should work" do
      @h.call(:splat => "baz.txt").should == @file
    end
  end

  describe "missing stuff" do
    before(:each) do
      File.should_receive(:directory?).with("/tmp/baz.txt").and_return(false)
      File.should_receive(:file?).with("/tmp/baz.txt").and_return(false)
    end

    it "should return not found" do
      lambda {
        @h.call(:splat => "baz.txt")
      }.should raise_error(Gopher::NotFoundError)
    end
  end
end
