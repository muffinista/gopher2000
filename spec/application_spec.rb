# frozen_string_literal: true

require File.join(File.dirname(__FILE__), '/spec_helper')
require 'tempfile'

describe Gopher::Application do
  before do
    @app = described_class.new
    @app.reset!
    @app.scripts = []
  end

  it 'has default host/port' do
    expect(@app.host).to eq('0.0.0.0')
    expect(@app.port).to eq(70)
  end

  describe 'should_reload?' do
    it 'is false if no scripts' do
      expect(@app.should_reload?).to be(false)
    end

    it 'does not do anything if last_reload not set' do
      expect(@app.last_reload).to be_nil
      @app.scripts << 'foo.rb'
      expect(@app.should_reload?).to be(false)
    end

    it 'checks script date' do
      now = Time.now
      allow(Time).to receive(:now).and_return(now)

      @app.last_reload = Time.now - 1000
      @app.scripts << 'foo.rb'
      expect(File).to receive(:mtime).with('foo.rb').and_return(now)

      expect(@app.should_reload?).to be(true)
    end
  end

  describe 'reload_stale' do
    it 'loads script and update last_reload' do
      now = Time.now
      allow(Time).to receive(:now).and_return(now)

      expect(@app).to receive(:should_reload?).and_return(true)

      @app.last_reload = Time.now - 1000
      @app.scripts << 'foo.rb'
      expect(@app).to receive(:load).with('foo.rb')
      @app.reload_stale

      expect(@app.last_reload).to eq(now)
    end
  end
end
