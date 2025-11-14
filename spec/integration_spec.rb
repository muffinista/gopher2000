# frozen_string_literal: true

require File.join(File.dirname(__FILE__), '/spec_helper')
require 'tempfile'

require File.join(File.dirname(__FILE__), '../lib/gopher2000/rspec.rb')

describe 'Integration tests', type: :integration do
  before do
    Gopher.application = './examples/simple.rb'
  end

  it 'works' do
    request '/'
    expect(response).to have_content('simple gopher example')
  end

  it 'has thread safety' do
    request '/counter'
    expect(response).to have_content('1')

    reset!
    request '/counter'
    expect(response).to have_content('1')
  end

  
  it 'has selector' do
    request '/'
    expect(response).to have_selector({ type: Gopher::Types::TEXT, text: 'current time' })

    follow 'current time'
    expect(response).to have_content 'It is currently'
  end

  it 'has direct route' do
    request '/gopher'
    expect(response).to have_content('Greetings from Gopher 2000!')
  end

  it 'can format text' do
    request '/prettytext'
    expect(response).to have_content("Lorem ipsum dolor sit amet,\r\n")

    expect(response).to have_content("Vivamus\r\n")
  end

  it 'can process input' do
    request '/'
    expect(response).to have_selector({ type: Gopher::Types::SEARCH, text: 'Hey, what is your name?' })

    follow 'Hey, what is your name?', search: 'Ishmael'
    expect(response).to have_selector({ type: Gopher::Types::INFO, text: 'Hello, Ishmael!' })
  end

  it 'supports helpers' do
    request '/junk'
    expect(response).to have_content('hhdhd')
  end

  it 'renders a "not found" result' do
    request '/missing-page'
    expect(response).to have_selector({ type: Gopher::Types::ERROR, text: 'Sorry, /missing-page was not found' })
  end

  it 'renders directory' do
    request '/'
    expect(response).to have_selector({ type: Gopher::Types::MENU, text: 'filez' })

    follow 'filez'

    expect(response).to have_selector({ type: Gopher::Types::INFO, text: /^Browsing/ })
    expect(response).to have_selector({ type: Gopher::Types::TEXT, text: '12345.txt', selector: '/files/12345.txt' })
  end

  it 'can handle routing params' do
    request '/request/abc/efg'
    expect(response).to have_selector({ type: Gopher::Types::INFO, text: '{x: "abc", y: "efg"}' })
    expect(response).to have_selector({ type: Gopher::Types::INFO, text: /#<Gopher::Request/ })
  end
end
