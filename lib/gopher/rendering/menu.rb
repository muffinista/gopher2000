module Gopher
  module Rendering
    # The MenuContext is for rendering gopher menus
    class Menu < Base
      NO_HOST = '(FALSE)'
      NO_PORT = 0

      # Sanitizes text for use in gopher menus
      def sanitize_text(raw)
        # text = raw.dup
        # text.rstrip! # Remove excess whitespace
        # text.gsub!(/\t/, ' ' * 8) # Tabs to spaces
        # text.gsub!(/\n/, '') # Get rid of newlines (\r as well?)
        # text
        raw.
          rstrip. # Remove excess whitespace
          gsub(/\t/, ' ' * 8). # Tabs to spaces
          gsub(/\n/, '') # Get rid of newlines (\r as well?)
      end

      # Creates a gopher menu line from +type+, +text+, +selector+, +host+ and +port+
      # +host+ and +post+ will default to the current host and port of the running Gopher server
      # (by default 0.0.0.0 and 70)
      # +text+ will be sanitized according to a few simple rules (see Gopher::Utils)
      #      def line(type, text, selector, host=Gopher::Server.host, port=Gopher::Server.port)
      def line(type, text, selector, host=nil, port=nil)
        text = sanitize_text(text)

        host = Gopher::Application.host if host.nil?
        port = Gopher::Application.port if port.nil?

        # no need to add a line-ending here, Base will handle that
        self << ["#{type}#{text}", selector, host, port].join("\t") + LINE_ENDING
      end

      def text(text, type = 'i')
        line type, text, 'null', NO_HOST, NO_PORT
      end

      def br(n=1)
        1.upto(n) do
          text 'i', ""
        end
      end

      def error(msg)
        text(msg, '3')
      end

      def directory(name, selector)
        line '1', name, selector
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
        when '.zip', '.gz', '.bz2' then '5'
        when '.gif' then 'g'
        when '.jpg', '.png' then 'I'
        when '.mp3', '.wav' then 's'
        else '0'
        end
      end
    end
  end
end
