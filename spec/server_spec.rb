require File.join(File.dirname(__FILE__), '/spec_helper')

describe Gopher::Server do
  before(:all) do

    # Configure
    Gopher.server do

      # Configure the main server
      config do
        host 'pha.hk'
        port 70
      end

      routing do
        route '/' do
          render :index
        end # How about a shortcut for this? route '/', :index ?
      end

      # Add some global templates
      templates do
        menu :index do
          text "pha.hk gopherspace"
        end
      end
    end
  end

  it 'should set the host and port' do
    Gopher::Server.host.should == 'pha.hk'
    Gopher::Server.port.should == 70
  end

  it 'should add the index template' do
    Gopher::Server.templates[:index].should_not be_empty
  end

  it 'should add the inline index gophlet to routes' do
    gophlet, args = Gopher::Server.router.lookup('/')
    gophlet.should be_instance_of(Gopher::InlineGophlet)
  end

  it 'should dispatch to the inline index gophlet' do
    result = Gopher::Server.dispatch('/')
    result.should == "ipha.hk gopherspace\tnull\t(FALSE)\t0\r\n"
  end
end
