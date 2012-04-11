require File.join(File.dirname(__FILE__), '/spec_helper')

class MockServer
  attr_accessor :menus, :text_templates, :params, :request
  include Gopher::Rendering

  def initialize
    @menus = {}
    @text_templates = {}
  end
end


describe Gopher::Rendering do
  before(:each) do
    @s = MockServer.new
  end

  describe "find_template" do
    it "should check in menus" do
      @s.menus['foo'] = "bar"
      @s.find_template('foo').should == ["bar", Gopher::Rendering::Menu]
    end
    it "should check in text_templates" do
      @s.text_templates['foo'] = "bar"
      @s.find_template('foo').should == ["bar", Gopher::Rendering::Text]
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

      @s.render(:foo).should == "xyz"
    end

    it "has access to request obj" do
      @s.request = "abc"
      @s.menu :foo do
        @request
      end

      @s.render(:foo).should == "abc"
    end

    it "rendering text access to request obj" do
      @s.request = "abc"
      @s.text :foo do
        @request
      end

      @s.render(:foo).should == "abc"
    end
  end

  describe "not_found_template" do
    before(:each) do
      @s.register_defaults
    end

    it "should use custom template if provided" do
      @s.not_found do ; end
      @s.not_found_template.should == :not_found
    end

    it "should use default otherwise" do
      @s.not_found_template.should == :'internal/not_found'
    end
  end

  describe "register_defaults" do
    it "should add to internal" do
      @s.find_template(:'internal/not_found').should be_nil
      @s.register_defaults
      @s.find_template(:'internal/not_found').should_not be_nil
    end
  end
end
