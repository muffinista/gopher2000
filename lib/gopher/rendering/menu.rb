module Gopher
  module Rendering
    # The MenuContext is for rendering gopher menus
    class Menu < Base

      # Sanitizes text for use in gopher menus
      def sanitize_text(raw)
        text = raw.dup
        text.rstrip! # Remove excess whitespace
        text.gsub!(/\t/, ' ' * 8) # Tabs to spaces
        text.gsub!(/\n/, '') # Get rid of newlines (\r as well?)
        text
      end

      # Creates a gopher menu line from +type+, +text+, +selector+, +host+ and +port+
      # +host+ and +post+ will default to the current host and port of the running Gopher server
      # (by default 0.0.0.0 and 70)
      # +text+ will be sanitized according to a few simple rules (see Gopher::Utils)
#      def line(type, text, selector, host=Gopher::Server.host, port=Gopher::Server.port)
      def line(type, text, selector, host=application.host, port=application.port)
        text = sanitize_text(text)

        self << ["#{type}#{text}", selector, host, port].join("\t")
#        self << "\r\n" # End the gopher line
      end

      def text(text)
        line 'i', text, 'null', '(FALSE)', 0
      end

      def link(text, selector, *args)
        type = determine_type(selector)
        line type, text, selector, *args
      end

      def search(text, selector, *args)
        line '7', text, selector, *args
      end
      alias input search

      def menu(text, selector, *args)
        line '1', text, selector, *args
      end

      # Determines the gopher type for +selector+ based on the extension
      def determine_type(selector)
        ext = File.extname(selector).downcase
        case ext
        when '.jpg', '.png' then 'I'
        when '.mp3', '.wav' then 's'
        else '0'
        end
      end
    end
  end
end
