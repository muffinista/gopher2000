require File.join(File.dirname(__FILE__), '/spec_helper')
require 'tempfile'

require File.join(File.dirname(__FILE__), '../lib/gopher2000/rspec.rb')

describe 'Integration tests', type: :integration do
  before do
    Gopher.application = "./examples/simple.rb"
  end

  
  it "works" do
    request "/"
    expect(response).to have_content('simple gopher example')
  end

  it 'has selector' do
    request "/"
    expect(response).to have_selector({type: Gopher::Types::TEXT, text: 'current time'})

    follow 'current time'
    expect(response).to have_content 'It is currently'
  end
end
