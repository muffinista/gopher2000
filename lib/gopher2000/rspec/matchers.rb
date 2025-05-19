# frozen_string_literal: true

module Gopher
  #
  # Matchers for integration specs
  #
  module RSpecMatchers
    def selectors_matching(expected, menu: client.menu)
      menu.select do |item|
        (expected[:type].nil? || (item[:type] == expected[:type])) &&
          (expected[:text].nil? || (item[:text] == expected[:text] || (expected[:text].is_a?(Regexp) && expected[:text].match?(item[:text])))) &&
          (expected[:selector].nil? || (item[:selector] == expected[:selector])) &&
          (expected[:host].nil? || (item[:host] == expected[:host])) &&
          (expected[:port].nil? || (item[:port] == expected[:port]))
      end
    end

    RSpec::Matchers.define :have_content do |expected|
      match do |actual|
        actual.response&.include?(expected)
      end

      failure_message do |actual|
        "expected output to contain #{expected}\n\n#{actual}"
      end
    end

    RSpec::Matchers.define :have_selector do |expected|
      match do |actual|
        selectors_matching(expected, menu: actual.menu).count == 1
      end

      failure_message do |actual|
        "expected menu to contain #{expected}\n\n#{actual.menu.join("\n")}"
      end
    end
  end
end
