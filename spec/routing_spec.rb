require File.join(File.dirname(__FILE__), '/spec_helper')

class MockServer
  attr_accessor :routes
  include Gopher::Routing
end

describe Gopher::Routing do
  before(:each) do
    @router = MockServer.new
  end

  pending "route"
  pending "default_route"

  describe "globify" do
    it "should add glob if none yet" do
      @router.globify("/foo").should == "/foo/?*"
    end

    it "should be ok with trailing slashes" do
      @router.globify("/foo/").should == "/foo/?*"
    end

    it "shouldn't add glob if there is one already" do
      @router.globify("/foo/*").should == "/foo/*"
    end
  end

  describe "mount" do
    before(:each) do
      @h = mock(Gopher::Handlers::DirectoryHandler)
      Gopher::Handlers::DirectoryHandler.should_receive(:new).with({:bar => :baz}).and_return(@h)
    end

    it "should work" do
      @router.mount("/foo", :bar => :baz)
    end
  end

  describe "compile" do
    it "should generate a basic string for routes without keys" do
      lookup, keys, block = @router.compile! "/foo" do; end
      lookup.to_s.should == /^\/foo$/.to_s
      keys.should == []
    end

    context "with keys" do
      it "should generate a lookup and keys for routes with keys" do
        lookup, keys, block = @router.compile! "/foo/:bar" do; end
        lookup.to_s.should == "(?-mix:^\\/foo\\/([^\\/?#]+)$)"

        keys.should == ["bar"]
      end

      it "should match correctly" do
        lookup, keys, block = @router.compile! "/foo/:bar" do; end
        lookup.to_s.should == "(?-mix:^\\/foo\\/([^\\/?#]+)$)"

        lookup.match("/foo/baz").should_not be_nil
        lookup.match("/foo2/baz").should be_nil
        lookup.match("/baz/foo/baz").should be_nil
        lookup.match("/foo/baz/bar").should be_nil
      end
    end

    context "with splat" do
      it "should work with splats" do
        lookup, keys, block = @router.compile! "/foo/*" do; end
        lookup.to_s.should == "(?-mix:^\\/foo\\/(.*?)$)"
        keys.should == ["splat"]
      end

      it "should match correctly" do
        lookup, keys, block = @router.compile! "/foo/*" do; end

        lookup.match("/foo/baz/bar/bam").should_not be_nil
        lookup.match("/foo2/baz").should be_nil
        lookup.match("/baz/foo/baz").should be_nil
      end
    end
  end
end
