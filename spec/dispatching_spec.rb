# frozen_string_literal: true

require File.join(File.dirname(__FILE__), '/spec_helper')

class MockApplication < Gopher::Application
  attr_accessor :menus, :routes, :config, :scripts, :last_reload

  def initialize
    @routes = []
    @menus = {}
    @scripts ||= []
    @config = {}

    register_defaults
  end
end

describe Gopher::Application do
  before do
    @server = MockApplication.new
  end

  describe 'lookup' do
    it 'works with simple route' do
      @server.route '/about' do
      end
      @request = Gopher::Request.new('/about')

      keys, = @server.lookup(@request.selector)
      expect(keys).to eq({})
    end
    
    it 'translates path' do
      @server.route '/about/:foo/:bar' do
      end
      @request = Gopher::Request.new('/about/x/y')

      keys, = @server.lookup(@request.selector)
      expect(keys).to eq({ foo: 'x', bar: 'y' })
    end

    it 'returns default route if no other route found, and default is defined' do
      @server.default_route do
        'DEFAULT ROUTE'
      end
      @request = Gopher::Request.new('/about/x/y')
      @response = @server.dispatch(@request)
      expect(@response.body).to eq('DEFAULT ROUTE')
      expect(@response.code).to eq(:success)
    end

    it 'responds with error if no route found' do
      @server.route '/about/:foo/:bar' do
      end
      @request = Gopher::Request.new('/junk/x/y')

      @response = @server.dispatch(@request)
      expect(@response.code).to eq(:missing)
      expect(@response.body).to contain_any_error
    end

    it 'responds with error if invalid request' do
      @server.route '/about/:foo/:bar' do
      end
      @request = Gopher::Request.new('x' * 256)

      @response = @server.dispatch(@request)
      expect(@response.code).to eq(:error)
      expect(@response.body).to contain_any_error
    end

    it "responds with error if there's an exception" do
      @server.route '/x' do
        raise StandardError
      end
      @request = Gopher::Request.new('/x')

      @response = @server.dispatch(@request)
      expect(@response.code).to eq(:error)
      expect(@response.body).to contain_any_error
    end

    it 'rejects long lookups' do
      @server.route '/about' do
      end
      @request = Gopher::Request.new('/0123456789' * 110)

      @response = @server.dispatch(@request)
      expect(@response.code).to eq(:error)
      expect(@response.body).to contain_any_error
    end

    context 'before_action' do
      it 'works' do
        @server.before_action do |selector, params|
          return selector, {'called' => true}
        end
        @server.route '/about' do
        end

        @request = Gopher::Request.new('/about')
        
        keys, = @server.lookup(@request.selector)
        expect(keys['called']).to be true
      end

      it 'can rewrite selector' do
        @server.before_action do |selector|
          return '/xyz'
        end
        @server.route '/about' do
          "ABOUT"
        end
        @server.route '/xyz' do
          "XYZ"
        end

        @request = Gopher::Request.new('/about')
        @response = @server.dispatch(@request)
        expect(@response.body).to eq('XYZ')
      end
    end
  end

  describe 'dispatch' do
    before do
      @server.route '/about' do
        'GOPHERTRON'
      end

      @request = Gopher::Request.new('/about')
    end

    it 'runs the block' do
      @response = @server.dispatch(@request)
      expect(@response.body).to eq('GOPHERTRON')
    end
  end

  describe 'dispatch, with params' do
    before do
      @server.route '/about/:x/:y' do
        params.to_a.join('/')
      end

      @request = Gopher::Request.new('/about/a/b')
    end

    it 'uses incoming params' do
      @response = @server.dispatch(@request)
      expect(@response.body).to eq('x/a/y/b')
    end
  end

  describe 'dispatch to mount' do
    before do
      @h = instance_double(Gopher::Handlers::DirectoryHandler)
      expect(@h).to receive(:application=).with(@server)
      expect(Gopher::Handlers::DirectoryHandler).to receive(:new).with({ bar: :baz,
                                                                         mount_point: '/foo' }).and_return(@h)

      @server.mount '/foo', bar: :baz
    end

    it 'works for root path' do
      @request = Gopher::Request.new('/foo')
      expect(@h).to receive(:call).with({ splat: '' }, @request)

      @response = @server.dispatch(@request)
      expect(@response.code).to eq(:success)
    end

    it 'works for subdir' do
      @request = Gopher::Request.new('/foo/bar')
      expect(@h).to receive(:call).with({ splat: 'bar' }, @request)

      @response = @server.dispatch(@request)
      expect(@response.code).to eq(:success)
    end
  end

  describe 'dispatch for URL requests' do
    let(:target) { 'URL:http://github.com/muffinista/gopher2000' }
    let(:request) { Gopher::Request.new(target) }
    let(:response) { @server.dispatch(request) }

    it 'returns web page' do
      expect(response.body).to include('<meta http-equiv="refresh" content="5;URL=http://github.com/muffinista/gopher2000">')
    end
  end

  describe 'globs' do
    before do
      @server.route '/about/*' do
        params[:splat]
      end
    end

    it 'puts wildcard into param[:splat]' do
      @request = Gopher::Request.new('/about/a/b')
      @response = @server.dispatch(@request)
      expect(@response.body).to eq('a/b')
    end
  end
end
