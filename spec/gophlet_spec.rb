require File.join(File.dirname(__FILE__), '/spec_helper')

describe Gopher::Gophlet do
  before(:all) do
    class Phlog < Gopher::Gophlet
      extend Gopher::Routing

      routing do
        route '/' do
          render :index
        end

        route '/foo/(.*)' do |foo|
          render :echo, foo
        end
      end

      templates do
        menu :index do
          text "Oh yeah"
        end

        menu :echo do |*a|
          text *a
        end
      end
    end

    @phlog = Phlog.new
  end

  it 'should add templates' do
    Phlog.templates.should include(:index)
  end

  it 'should accept dispatches' do
    @phlog.dispatch('/').should == "iOh yeah\tnull\t(FALSE)\t0\r\n"
  end

  it 'should accept dispatches' do
    @phlog.dispatch('/foo/zomg').should == "izomg\tnull\t(FALSE)\t0\r\n"
  end
end
