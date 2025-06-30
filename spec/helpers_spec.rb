# frozen_string_literal: true

require File.join(File.dirname(__FILE__), '/spec_helper')

describe Gopher::Application do
  before do
    @obj = described_class.new
    #    @obj.extend(Gopher::Helpers)
  end

  it 'adds code to target class' do
    @obj.helpers do
      def foo = 'FOO'
    end

    expect(@obj.foo).to eq('FOO')
  end
end
