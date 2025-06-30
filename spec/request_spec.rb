# frozen_string_literal: true

require File.join(File.dirname(__FILE__), '/spec_helper')

describe Gopher::Request do
  it 'splits raw request' do
    request = described_class.new("foo\tbar")
    expect(request.selector).to eq('/foo')
    expect(request.input).to eq('bar')
  end

  it 'normalizes by adding a slash to the front' do
    request = described_class.new('foo')
    expect(request.selector).to eq('/foo')
  end

  it 'is ok with just selector' do
    request = described_class.new('/foo')
    expect(request.selector).to eq('/foo')
    expect(request.input).to be_nil
  end

  it 'accepts ip_address' do
    request = described_class.new('foo', 'bar')
    expect(request.ip_address).to eq('bar')
  end

  it 'valid? == true for valid selectors' do
    request = described_class.new('x' * 254, 'bar')
    expect(request.valid?).to be(true)
  end

  it 'valid? == false for invalid selectors' do
    request = described_class.new('x' * 255, 'bar')
    expect(request.valid?).to be(false)
  end

  it 'detects urls' do
    request = described_class.new('URL:http://github.com/muffinista/gopher2000')
    expect(request).to be_url
    expect(request.url).to eql('http://github.com/muffinista/gopher2000')
  end
end
