require File.join(File.dirname(__FILE__), '/../spec_helper')

describe Gopher::Rendering::Menu do
  before(:each) do
    @app = Gopher::Application.new
    @app.reset!
    @app.config[:host] = "host"
    @app.config[:port] = 1234

    @ctx = Gopher::Rendering::Menu.new(@app)
  end

  it 'should add text as a gopher line' do
    @ctx.text("gopher forever")
    expect(@ctx.result).to eq("igopher forever\tnull\t(FALSE)\t0\r\n")
  end

  describe "sanitize_text" do
    it "should remove extra whitespace from end of line" do
      expect(@ctx.sanitize_text("x   ")).to eq("x")
    end

    it "should convert tabs to spaces" do
      expect(@ctx.sanitize_text("x\tx")).to eq("x        x")
    end

    it "should remove newlines" do
      expect(@ctx.sanitize_text("x\nx")).to eq("xx")
    end
  end

  describe "line" do
    it "should work" do
      expect(@ctx.line("type", "text", "selector", "host", "port")).to eq("typetext\tselector\thost\tport\r\n")
    end

    it "should use application host/port as defaults" do
      expect(@ctx.line("type", "text", "selector")).to eq("typetext\tselector\thost\t1234\r\n")
    end
  end

  describe "error" do
    it "should call text with right selector" do
      expect(@ctx).to receive(:text).with("foo", '3')
      @ctx.error("foo")
    end
  end

  describe "directory" do
    it "should call link with right selector" do
      expect(@ctx).to receive(:line).with("1", "foo", "/bar/foo", nil, nil)
      @ctx.directory("foo", "/bar/foo")
    end
  end

  describe "link" do
    it "should get type with determine_type" do
      expect(@ctx).to receive(:determine_type).with("foo.txt").and_return("A")
      expect(@ctx.link("FILE", "foo.txt")).to eq("AFILE\tfoo.txt\thost\t1234\r\n")
    end
  end

  describe "http" do
    it "should work" do
      expect(@ctx.http("weblink", "http://google.com")).to eq("hweblink\tURL:http://google.com\thost\t1234\r\n")
    end
  end

  describe "search" do
    it "should output link type/text" do
      expect(@ctx.search("FIND", "search")).to eq("7FIND\tsearch\thost\t1234\r\n")
    end
  end

  describe "menu" do
    it "should output link type/text" do
      expect(@ctx.menu("MENU ITEM", "item")).to eq("1MENU ITEM\titem\thost\t1234\r\n")
    end
  end

  describe "br" do
    it "should generate an empty text line" do
      expect(@ctx).to receive(:text).with("i", "")
      @ctx.br
    end

    it "should call #text multiple times" do
      expect(@ctx).to receive(:text).twice.with("i", "")
      @ctx.br(2)
    end

    it "should output an empty menu item" do
      @ctx.br
      expect(@ctx.result).to eq("i\tnull\t(FALSE)\t0\r\n")
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
        expect(@ctx.determine_type(file)).to eq(expected)
      end
    end
  end
end
