require File.join(File.dirname(__FILE__), '/../spec_helper')

describe Gopher::Rendering::Base do
  before(:each) do
    @ctx = Gopher::Rendering::Base.new
  end

  it 'should add text' do
    @ctx.text("line 1")
    @ctx.text("line 2")
    expect(@ctx.result).to eq("line 1\r\nline 2\r\n")
  end

  it "should add breaks correctly" do
    @ctx.spacing 2
    @ctx.text("line 1")
    @ctx.text("line 2")
    expect(@ctx.result).to eq("line 1\r\n\r\nline 2\r\n\r\n")
  end

  it "br outputs a bunch of newlines" do
    expect(@ctx.br(2)).to eq("\r\n\r\n")
  end

  describe "underline" do
    it "underline outputs a pretty line" do
      expect(@ctx.underline(1, 'x')).to eq("x\r\n")
    end
    it "has defaults" do
      expect(@ctx.underline).to eq("=" * 70 + "\r\n")
    end
  end

  describe "figlet" do
    it "outputs a figlet" do
      expect(@ctx.figlet('pie')).to eq("        _      \r\n       (_)     \r\n  _ __  _  ___ \r\n | '_ \\| |/ _ \\\r\n | |_) | |  __/\r\n | .__/|_|\\___|\r\n | |           \r\n |_|           \r\n")
    end
  end


  describe "big_header" do
    it "outputs a box with text" do
      @ctx.width(5)
      expect(@ctx.big_header('pie')).to eq("\r\n=====\r\n=pie=\r\n=====\r\n\r\n")
    end
  end

  describe "header" do
    it "outputs underlined text" do
      @ctx.width(5)
      expect(@ctx.header('pie')).to eq(" pie \r\n=====\r\n")
    end
  end

  it "uses to_s to output result" do
    @ctx.text("line 1")
    expect(@ctx.to_s).to eq(@ctx.result)
  end

  describe "block" do
    it "wraps text" do
      expect(@ctx).to receive(:text).twice.with "a"
      @ctx.block("a a",1)
    end
  end
end
