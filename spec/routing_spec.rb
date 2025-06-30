# frozen_string_literal: true

require File.join(File.dirname(__FILE__), '/spec_helper')

class MockServer < Gopher::Application
  #  attr_accessor :routes
  #  include Gopher::Routing
end

describe Gopher::Application do
  before do
    @router = MockServer.new
  end

  describe 'default_route' do
    it 'sets route as default' do
      @router.default_route do
        'hi'
      end
      _, block = @router.lookup('sfssfdfsfsd')
      expect(block.class).to eql(UnboundMethod)
    end
  end

  describe 'globify' do
    it 'adds glob if none yet' do
      expect(@router.globify('/foo')).to eq('/foo/?*')
    end

    it 'is ok with trailing slashes' do
      expect(@router.globify('/foo/')).to eq('/foo/?*')
    end

    it 'does not add glob if there is one already' do
      expect(@router.globify('/foo/*')).to eq('/foo/*')
    end
  end

  describe 'mount' do
    it 'works' do
      @h = instance_double(Gopher::Handlers::DirectoryHandler)
      expect(@h).to receive(:application=).with(@router)

      expect(Gopher::Handlers::DirectoryHandler).to receive(:new).with({ bar: :baz,
                                                                         mount_point: '/foo' }).and_return(@h)

      @router.mount('/foo', bar: :baz)
    end
  end

  describe 'compile' do
    it 'generates a basic string for routes without keys' do
      lookup, keys, = @router.compile! '/foo' do
      end
      expect(lookup.to_s).to eq(%r{^/foo$}.to_s)
      expect(keys).to eq([])
    end

    context 'with keys' do
      it 'generates a lookup and keys for routes with keys' do
        lookup, keys, = @router.compile! '/foo/:bar' do
        end
        expect(lookup.to_s).to eq('(?-mix:^\\/foo\\/([^\\/?#]+)$)')

        expect(keys).to eq(['bar'])
      end

      it 'matches correctly' do
        lookup, = @router.compile! '/foo/:bar' do
        end
        expect(lookup.to_s).to eq('(?-mix:^\\/foo\\/([^\\/?#]+)$)')

        expect(lookup.match('/foo/baz')).not_to be_nil
        expect(lookup.match('/foo2/baz')).to be_nil
        expect(lookup.match('/baz/foo/baz')).to be_nil
        expect(lookup.match('/foo/baz/bar')).to be_nil
      end
    end

    context 'with splat' do
      it 'works with splats' do
        lookup, keys, = @router.compile! '/foo/*' do
        end
        expect(lookup.to_s).to eq('(?-mix:^\\/foo\\/(.*?)$)')
        expect(keys).to eq(['splat'])
      end

      it 'matches correctly' do
        lookup, = @router.compile! '/foo/*' do
        end

        expect(lookup.match('/foo/baz/bar/bam')).not_to be_nil
        expect(lookup.match('/foo2/baz')).to be_nil
        expect(lookup.match('/baz/foo/baz')).to be_nil
      end
    end
  end
end
