require File.join(File.dirname(__FILE__), '/spec_helper')

describe Gopher::Routing, 'with a mock gophlet' do
  before(:all) do
    class OuterGophlet < Gopher::Gophlet; end

    class InnerGophlet < Gopher::Gophlet
      def self.expected_arguments; /[a-z]*/ end # For most gophlets, this will simply be /\/.*/
    end

    @app = OuterGophlet
    @app.extend(Gopher::Routing)

    @app.routing do
      route '/foo', InnerGophlet
      
      route '/' do
        return '-'
      end
    end
  end

  it 'should route /foo to the mock gophlet' do
    gophlet, args = @app.router.lookup('/foo')

    gophlet.should be_instance_of(InnerGophlet)
    args.should == ''
  end

  it 'should route /foo/excellent to the mock gophlet' do
    gophlet, args = @app.router.lookup('/foo/excellent')

    gophlet.should be_instance_of(InnerGophlet)
    args.should == '/excellent'
  end

  it 'should not route non-matches to the gophlet' do
    proc { @app.router.lookup('/foo/123') }.should raise_error(Gopher::NotFound)
    proc { @app.router.lookup('/foo//excellent') }.should raise_error(Gopher::NotFound)
  end

  it 'should route to gophlets defined inline' do
    @app.router.lookup("/").should_not be_empty
  end
end
