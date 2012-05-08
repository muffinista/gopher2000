module Gopher
  module Rendering
    #
    # The MenuContext is for rendering gopher menus in the "pseudo
    # file-system hierarchy" defined by RFC1436
    #
    # @see http://www.ietf.org/rfc/rfc1436.txt
    #
    class Menu < Base

      # default host value when rendering a line with no selector
      NO_HOST = '(FALSE)'

      # default port value when rendering a line with no selector
      NO_PORT = 0

      # Sanitizes text for use in gopher menus
      # @param [String] raw text to cleanup
      # @return string that can be used in a gopher menu
      def sanitize_text(raw)
        raw.
          rstrip. # Remove excess whitespace
          gsub(/\t/, ' ' * 8). # Tabs to spaces
          gsub(/\n/, '') # Get rid of newlines (\r as well?)
      end

      #
      # output a gopher menu line
      #
      # @param [String] type what sort of entry is this? @see http://www.ietf.org/rfc/rfc1436.txt for a list
      # @param [String] text the text of the line
      # @param [String] selector if this is a link, the path of the route we are linking to
      # @param [String] host for link, defaults to current host
      # @param [String] port for link, defaults to current port
      def line(type, text, selector, host=nil, port=nil)
        text = sanitize_text(text)

        host = application.host if host.nil?
        port = application.port if port.nil?

        self << ["#{type}#{text}", selector, host, port].join("\t") + LINE_ENDING
      end

      #
      # output a line of text, with no selector
      # @param [String] text the text of the line
      # @param [String] type what sort of entry is this? @see http://www.ietf.org/rfc/rfc1436.txt for a list
      #
      def text(text, type = 'i')
        line type, text, 'null', NO_HOST, NO_PORT
      end

      #
      # add some empty lines to the menu
      # @param [integer] n how many breaks to add
      #
      def br(n=1)
        1.upto(n) do
          text 'i', ""
        end
        self.to_s
      end

      #
      # output an error message
      # @param [String] msg text of the message
      #
      def error(msg)
        text(msg, '3')
      end

      #
      # output a link to a sub-menu/directory
      # @param [String] name of the menu/directory
      # @param [String] selector we are linking to
      # @param [String] host for link, defaults to current host
      # @param [String] port for link, defaults to current port
      #
      def directory(name, selector, host=nil, port=nil)
        line '1', name, selector, host, port
      end
      alias menu directory


      #
      # output a menu link
      #
      # @param [String] text the text of the link
      # @param [String] selector the path of the link. the extension of this path will be used to
      #   detemine the type of link -- image, archive, etc. If you want
      #   to specify a specific link-type, you should use the text
      #   method instead
      # @param [String] host for link, defaults to current host
      # @param [String] port for link, defaults to current port
      def link(text, selector, host=nil, port=nil)
        type = determine_type(selector)
        line type, text, selector, host, port
      end

      #
      # output a search entry
      # @param [String] text the text of the link
      # @param [String] selector the path of the selector
      def search(text, selector, *args)
        line '7', text, selector, *args
      end
      alias input search


      #
      # Determines the gopher type for +selector+ based on the
      # extension. This is a pretty simple check based on the entities
      # list in http://www.ietf.org/rfc/rfc1436.txt
      # @param [String] selector presumably a link to a file name with an extension
      # @return gopher selector type
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
