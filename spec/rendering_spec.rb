require File.join(File.dirname(__FILE__), '/spec_helper')

class MockServer < Gopher::Application
  attr_accessor :menus, :text_templates, :params, :request

  def initialize
    @menus = {}
    @text_templates = {}
  end
end


describe Gopher::Application do
  before(:each) do
    @s = MockServer.new
  end

  describe "find_template" do
    it "should check in menus" do
      @s.menus['foo'] = "bar"
      expect(@s.find_template('foo')).to eq(["bar", Gopher::Rendering::Menu])
    end
    it "should check in text_templates" do
      @s.text_templates['foo'] = "bar"
      expect(@s.find_template('foo')).to eq(["bar", Gopher::Rendering::Text])
    end
  end

  describe "render" do
    it "should raise error if no such template" do
      expect{@s.render('xyzzy')}.to raise_error(Gopher::TemplateNotFound)
    end

    it "has access to params obj" do
      @s.params = "xyz"
      @s.menu :foo do
        @params
      end

      expect(@s.render(:foo)).to eq("xyz")
    end

    it "has access to request obj" do
      @s.request = "abc"
      @s.menu :foo do
        @request
      end

      expect(@s.render(:foo)).to eq("abc")
    end

    it "rendering text access to request obj" do
      @s.request = "abc"
      @s.text :foo do
        @request
      end

      expect(@s.render(:foo)).to eq("abc")
    end
  end

  describe "not_found_template" do
    before(:each) do
      @s.reset!
    end

    it "should use custom template if provided" do
      @s.not_found do ; end
      expect(@s.not_found_template).to eq(:not_found)
    end

    it "should use default otherwise" do
      expect(@s.not_found_template).to eq(:'internal/not_found')
    end
  end

  # describe "register_defaults" do
  #   it "should add to internal" do
  #     @s.find_template(:'internal/not_found').should be_nil
  #     @s.register_defaults
  #     @s.find_template(:'internal/not_found').should_not be_nil
  #   end
  # end
end
