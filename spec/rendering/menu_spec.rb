require File.join(File.dirname(__FILE__), '/../spec_helper')

describe Gopher::Rendering::Menu do
  before(:each) do
    app = mock(Gopher::Application,
      :host => "host",
      :port => 1234)

    @ctx = Gopher::Rendering::Menu.new(app)
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
      @ctx.line("type", "text", "selector", "host", "port").should == "typetext\tselector\thost\tport"
    end

    it "should use application host/port as defaults" do
      @ctx.line("type", "text", "selector").should == "typetext\tselector\thost\t1234"
    end
  end

  describe "error" do
    it "should call text with right selector" do
      @ctx.should_receive(:text).with("foo", '3')
      @ctx.error("foo")
    end
  end

  describe "directory" do
    it "should call link with right selector" do
      @ctx.should_receive(:link).with("foo", '1')
      @ctx.directory("foo")
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

  context "determine_type" do
    {
      "foo.zip" => '5',
      "foo.gz" => '5',
      "foo.bz2" => '5',
      "foo.gif" => 'g',
      "foo.jpg" => 'I',
      "foo.png" => 'I',
      "foo.mp3" => 's',
      "foo.wav" => 's',
      "foo.random-file" => "0"
    }.each do |file, expected|
      it "should have right selector for #{file}" do
        @ctx.determine_type(file).should == expected
      end
    end
  end
end
