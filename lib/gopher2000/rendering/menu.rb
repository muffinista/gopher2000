# frozen_string_literal: true

module Gopher
  #
  # Code related to rendering
  #
  module Rendering
    require 'mimemagic'

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
        raw
          .rstrip # Remove excess whitespace
          .gsub("\t", ' ' * 8) # Tabs to spaces
          .gsub("\n", '') # Get rid of newlines (\r as well?)
      end

      #
      # output a gopher menu line
      #
      # @param [String] type what sort of entry is this? @see http://www.ietf.org/rfc/rfc1436.txt for a list
      # @param [String] text the text of the line
      # @param [String] selector if this is a link, the path of the route we are linking to
      # @param [String] host for link, defaults to current host
      # @param [String] port for link, defaults to current port
      def line(type, text, selector, host = nil, port = nil)
        text = sanitize_text(text)

        host = application.host if host.nil?
        port = application.port if port.nil?

        self << (["#{type}#{text}", selector, host, port].join("\t") + LINE_ENDING)
      end

      #
      # output a line of text, with no selector
      # @param [String] text the text of the line
      # @param [String] type what sort of entry is this? @see http://www.ietf.org/rfc/rfc1436.txt for a list
      #
      def text(text, type = Gopher::Types::INFO)
        line type, text, 'null', NO_HOST, NO_PORT
      end

      #
      # add some empty lines to the menu
      # @param [integer] n how many breaks to add
      #
      def br(n = 1)
        1.upto(n) do
          text Gopher::Types::INFO, ''
        end
        to_s
      end

      #
      # output an error message
      # @param [String] msg text of the message
      #
      def error(msg)
        text(msg, Gopher::Types::ERROR)
      end

      #
      # output a link to a sub-menu/directory
      # @param [String] name of the menu/directory
      # @param [String] selector we are linking to
      # @param [String] host for link, defaults to current host
      # @param [String] port for link, defaults to current port
      #
      def directory(name, selector, host = nil, port = nil)
        line Gopher::Types::MENU, name, selector, host, port
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
      # @param [String] real filepath of the link
      # @param [String] selector type. if not specified, we will guess
      def link(text, selector, host = nil, port = nil, filepath = nil, type = nil)
        type ||= determine_type(filepath || selector)
        line type, text, selector, host, port
      end

      #
      # output a link to text output
      #
      # @param [String] text the text of the link
      # @param [String] selector the path of the link. the extension of this path will be used to
      #   detemine the type of link -- image, archive, etc. If you want
      #   to specify a specific link-type, you should use the text
      #   method instead
      # @param [String] host for link, defaults to current host
      # @param [String] port for link, defaults to current port
      # @param [String] real filepath of the link
      def text_link(text, selector, host = nil, port = nil, filepath = nil)
        link(text, selector, host, port, filepath, Gopher::Types::TEXT)
      end

      # Create an HTTP link entry. This is how this works (via wikipedia)
      #
      # For example, to create a link to http://gopher.quux.org/, the
      # item type is "h", the display string is the title of the link,
      # the item selector is "URL:http://gopher.quux.org/", and the
      # domain and port are that of the originating Gopher server (so
      # that clients that do not support URL links will query the
      # server and receive an HTML redirection page).
      #
      # @param [String] text the text of the link
      # @param [String] URL of the link
      # @param [String] host for link, defaults to current host
      # @param [String] port for link, defaults to current port
      def http(text, url, host = nil, port = nil)
        line Gopher::Types::HTML, text, "URL:#{url}", host, port
      end

      #
      # output a search entry
      # @param [String] text the text of the link
      # @param [String] selector the path of the selector
      def search(text, selector, *)
        line(Gopher::Types::SEARCH, text, selector, *)
      end
      alias input search

      #
      # Determines the gopher type for +selector+ based on the
      # information stored in the shared mime database.
      # @param [String] filepath The full path to the file (should also exist, if possible)
      # @return gopher selector type
      #
      def determine_type(filepath)
        # Determine MIME type by path
        mimetype = MimeMagic.by_path(filepath)

        # Determine MIME type by contents
        unless mimetype
          begin
            # Open file
            file = File.open(filepath)

            # Try to detect MIME type using by recognition of typical characters
            mimetype = MimeMagic.by_magic(file)

            unless mimetype
              file.rewind

              # Read up to 1k of file data and look for a "\0\0" sequence (typical for binary files)
              mimetype = if file.read(1000).include?("\0\0")
                           MimeMagic.new('application/octet-stream')
                         else
                           MimeMagic.new('text/plain')
                         end

              file.close
            end
          rescue SystemCallError, IOError
            nil
          end
        end

        unless mimetype
          ext = File.extname(filepath).split('.').last
          mimetype = MimeMagic.by_extension(ext)
        end

        if !mimetype
          Gopher::Types::BINARY # Binary file
        elsif mimetype.child_of?('application/gzip') ||
              mimetype.child_of?('application/x-bzip') ||
              mimetype.child_of?('application/zip')
          Gopher::Types::ARCHIVE # archive
        elsif mimetype.child_of?('image/gif')
          Gopher::Types::GIF # GIF image
        elsif mimetype.child_of?('text/x-uuencode')
          Gopher::Types::UUENCODED # UUEncode encoded file
        elsif mimetype.child_of?('application/mac-binhex40')
          Gopher::Types::BINHEX # BinHex encoded file
        elsif mimetype.child_of?('text/html') || mimetype.child_of?('application/xhtml+xml')
          Gopher::Types::HTML # HTML file
        elsif mimetype.mediatype == 'text' || mimetype.child_of?('text/plain')
          Gopher::Types::TEXT # General text file
        elsif mimetype.mediatype == 'image'
          Gopher::Types::IMAGE # General image file
        elsif mimetype.mediatype == 'audio'
          Gopher::Types::AUDIO # General audio file
        elsif mimetype.mediatype == 'video'
          Gopher::Types::VIDEO # General video file
        else
          Gopher::Types::BINARY # Binary file
        end
      end
    end
  end
end
