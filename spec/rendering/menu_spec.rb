require File.join(File.dirname(__FILE__), '/../spec_helper')

describe Gopher::Rendering::Menu do
  before(:each) do
    @ctx = Gopher::Rendering::Menu.new

    application.stub!(:host).and_return("host")
    application.stub!(:port).and_return(1234)
  end

  it 'should add text as a gopher line' do
    @ctx.text("gopher forever")

    # note that there's no line ending here because Base#<< will add that
    @ctx.result.should == "igopher forever\tnull\t(FALSE)\t0"
  end

  describe "sanitize_text" do
    it "should remove extra whitespace from end of line" do
      @ctx.sanitize_text("x   ").should == "x"
    end

    it "should convert tabs to spaces" do
      @ctx.sanitize_text("x\tx").should == "x        x"
    end

    it "should remove newlines" do
      @ctx.sanitize_text("x\nx").should == "xx"
    end
  end

  describe "line" do
    it "should work" do
      #def line(type, text, selector, host=application.host, port=application.port)
      @ctx.line("type", "text", "selector", "host", "port").should == "typetext\tselector\thost\tport"
    end

    it "should use application host/port as defaults" do
      @ctx.line("type", "text", "selector").should == "typetext\tselector\thost\t1234"
    end
  end

  describe "link" do
    it "should get type with determine_type" do
      @ctx.should_receive(:determine_type).with("foo.txt").and_return("A")
      @ctx.link("FILE", "foo.txt").should == "AFILE\tfoo.txt\thost\t1234"
    end
  end

  describe "search" do
    it "should output link type/text" do
      @ctx.search("FIND", "search").should == "7FIND\tsearch\thost\t1234"
    end
  end

  describe "menu" do
    it "should output link type/text" do
      @ctx.menu("MENU ITEM", "item").should == "1MENU ITEM\titem\thost\t1234"
    end
  end

  pending "determine_type"
end
