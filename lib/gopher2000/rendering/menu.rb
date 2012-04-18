module Gopher
  module Rendering
    #
    # The MenuContext is for rendering gopher menus in the "pseudo
    # file-system hierarchy" defined by RFC1436
    #
    # @see http://www.ietf.org/rfc/rfc1436.txt
    #
    class Menu < Base
      NO_HOST = '(FALSE)'
      NO_PORT = 0

      # Sanitizes text for use in gopher menus
      def sanitize_text(raw)
        raw.
          rstrip. # Remove excess whitespace
          gsub(/\t/, ' ' * 8). # Tabs to spaces
          gsub(/\n/, '') # Get rid of newlines (\r as well?)
      end

      #
      # output a gopher menu line
      #
      # +type+ -- what sort of entry is this? @see http://www.ietf.org/rfc/rfc1436.txt for a list
      # +text+ -- the text of the line
      # +selector+ -- if this is a link, the path of the route we are linking to
      # +host+ and +post+ will default to the current host and port of the server
      def line(type, text, selector, host=nil, port=nil)
        text = sanitize_text(text)

        host = application.host if host.nil?
        port = application.port if port.nil?

        self << ["#{type}#{text}", selector, host, port].join("\t") + LINE_ENDING
      end

      #
      # output a line of text, with no selector
      #
      def text(text, type = 'i')
        line type, text, 'null', NO_HOST, NO_PORT
      end

      #
      # add some empty lines to the menu
      #
      def br(n=1)
        1.upto(n) do
          text 'i', ""
        end
        self.to_s
      end

      #
      # output an error message
      #
      def error(msg)
        text(msg, '3')
      end

      #
      # output a link to a sub-menu/directory
      #
      def directory(name, selector, host=nil, port=nil)
        line '1', name, selector, host, port
      end
      alias menu directory


      #
      # output a menu link
      #
      # text -- the text of the link
      # selector -- the path of the link. the extension of this path will be used to
      # detemine the type of link -- image, archive, etc. If you want
      # to specify a specific link-type, you should use the text
      # method instead
      #
      def link(text, selector, host=nil, port=nil)
        type = determine_type(selector)
        line type, text, selector, host, port
      end

      #
      # output a search entry
      # text - text of the selector
      # selector -- the path to call
      #
      def search(text, selector, *args)
        line '7', text, selector, *args
      end
      alias input search


      #
      # Determines the gopher type for +selector+ based on the
      # extension. This is a pretty simple check based on the entities
      # list in http://www.ietf.org/rfc/rfc1436.txt
      #
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
