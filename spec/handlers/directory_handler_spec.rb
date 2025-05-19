# frozen_string_literal: true

require File.join(File.dirname(__FILE__), '..', '/spec_helper')

describe Gopher::Handlers::DirectoryHandler do
  before do
    app = instance_double(Gopher::Application,
                          host: 'host',
                          port: 1234,
                          config: {})

    @h = described_class.new(path: '/tmp', mount_point: '/xyz/123')
    @h.application = app
  end

  describe 'filtering' do
    it 'uses right filter' do
      expect(File).to receive(:directory?).with('/tmp/bar/baz').and_return(true)
      expect(File).to receive(:directory?).with('/tmp/bar/baz/a.txt').and_return(false)
      expect(File).to receive(:directory?).with('/tmp/bar/baz/b.exe').and_return(false)
      expect(File).to receive(:directory?).with('/tmp/bar/baz/dir2').and_return(true)

      expect(File).to receive(:file?).with('/tmp/bar/baz/a.txt').and_return(true)
      expect(File).to receive(:file?).with('/tmp/bar/baz/b.exe').and_return(true)

      expect(File).to receive(:fnmatch).with('*.txt', '/tmp/bar/baz/a.txt').and_return(true)
      expect(File).to receive(:fnmatch).with('*.txt', '/tmp/bar/baz/b.exe').and_return(false)

      expect(Dir).to receive(:glob).with('/tmp/bar/baz/*').and_return([
                                                                        '/tmp/bar/baz/a.txt',
                                                                        '/tmp/bar/baz/b.exe',
                                                                        '/tmp/bar/baz/dir2'
                                                                      ])

      @h.filter = '*.txt'
      @h.call(splat: 'bar/baz')
    end
  end

  describe 'request_path' do
    it 'joins existing path with incoming path' do
      expect(@h.request_path(splat: 'bar/baz')).to eq('/tmp/bar/baz')
    end
  end

  describe 'to_selector' do
    it 'works' do
      expect(@h.to_selector('/tmp/foo/bar.html')).to eq('/xyz/123/foo/bar.html')
      expect(@h.to_selector('/tmp/foo/baz')).to eq('/xyz/123/foo/baz')
      expect(@h.to_selector('/tmp')).to eq('/xyz/123')
    end
  end

  describe 'contained?' do
    it 'is false if not under base path' do
      expect(@h.contained?('/home/gopher')).to be(false)
    end

    it 'is true if under base path' do
      expect(@h.contained?('/tmp/gopher')).to be(true)
    end
  end

  describe 'safety checks' do
    it 'raises exception for invalid directory' do
      expect do
        expect(@h.call(splat: '../../../home/foo/bar/baz').to_s).to eq("0a\t/tmp/bar/baz/a\thost\t1234")
      end.to raise_error(Gopher::InvalidRequest)
    end
  end

  describe 'directories' do
    it 'works' do
      expect(File).to receive(:directory?).with('/tmp/bar/baz').and_return(true)
      expect(File).to receive(:directory?).with('/tmp/bar/baz/a').and_return(false)
      expect(File).to receive(:directory?).with('/tmp/bar/baz/dir2').and_return(true)

      expect(File).to receive(:file?).with('/tmp/bar/baz/a').and_return(true)
      expect(File).to receive(:fnmatch).with('*.*', '/tmp/bar/baz/a').and_return(true)

      expect(Dir).to receive(:glob).with('/tmp/bar/baz/*').and_return([
                                                                        '/tmp/bar/baz/a',
                                                                        '/tmp/bar/baz/dir2'
                                                                      ])

      expect(@h.call(splat: 'bar/baz').to_s).to eq("iBrowsing: /tmp/bar/baz\tnull\t(FALSE)\t0\r\n9a\t/xyz/123/bar/baz/a\thost\t1234\r\n1dir2\t/xyz/123/bar/baz/dir2\thost\t1234\r\n")
    end
  end

  describe 'files' do
    it 'works' do
      @file = instance_double(File)
      expect(File).to receive(:directory?).with('/tmp/baz.txt').and_return(false)

      expect(File).to receive(:file?).with('/tmp/baz.txt').and_return(true)
      expect(File).to receive(:new).with('/tmp/baz.txt').and_return(@file)

      expect(@h.call(splat: 'baz.txt')).to eq(@file)
    end
  end

  describe 'missing stuff' do
    it 'returns not found' do
      expect(File).to receive(:directory?).with('/tmp/baz.txt').and_return(false)
      expect(File).to receive(:file?).with('/tmp/baz.txt').and_return(false)

      expect do
        @h.call(splat: 'baz.txt')
      end.to raise_error(Gopher::NotFoundError)
    end
  end
end
