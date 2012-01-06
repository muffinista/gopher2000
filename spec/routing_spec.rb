require File.join(File.dirname(__FILE__), '/spec_helper')

class MockServer
  attr_accessor :routes
  include Gopher::Routing
end

describe Gopher::Routing do
  before(:each) do
    @router = MockServer.new
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
