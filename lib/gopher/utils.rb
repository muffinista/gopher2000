module Gopher
  module Utils
    # Sanitizes a gopher selector
    def self.sanitize_selector(raw)
      selector = raw.to_s.dup
      selector.strip! # Strip whitespace
      selector.sub!(/\/$/, '') # Strip last rslash
      selector.sub!(/^\/*/, '/') # Strip extra lslashes
      selector.gsub!(/\.+/, '.') # Don't want consecutive dots!
      selector
    end

    # Sanitizes text for use in gopher menus
    def self.sanitize_text(raw)
      text = raw.dup
      text.rstrip! # Remove excess whitespace
      text.gsub!(/\t/, ' ' * 8) # Tabs to spaces
      text.gsub!(/\n/, '') # Get rid of newlines (\r as well?)
      text
    end

    # Determines the gopher type for +selector+ based on the extension
    def self.determine_type(selector)
      ext = File.extname(selector).downcase
      case ext
      when '.jpg', '.png' then 'I'
      when '.mp3', '.wav' then 's'
      else '0'
      end
    end
  end
end
