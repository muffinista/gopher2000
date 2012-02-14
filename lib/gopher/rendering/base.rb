module Gopher
  module Rendering

    # "A CR LF denotes the end of the item." RFC 1436
    # @see http://www.faqs.org/rfcs/rfc1436.html
    LINE_ENDING = "\r\n"

    # All rendering of templates (inline and otherwise) is done inside a RenderContext
    class Base
      attr_accessor :result, :spacing, :request, :params

      def initialize(host=nil) # nodoc
        @_host = host
        @result = ""
        @spacing = 1
      end

      def <<(string); @result << string.to_s; end

      # Adds +text+ to the result
      def text(text)
        self << text
        add_spacing
      end

      def spacing(n)
        @spacing = n.to_i
      end

      # Adds +n+ empty lines
      def br(n=1)
        self << (LINE_ENDING * n)
      end

      #
      # borrowed and modified from ActionView -- wrap text at specified width
      # returning an array of lines for now in case we want to do nifty processing with them
      #
      # File actionpack/lib/action_view/helpers/text_helper.rb, line 217
      def word_wrap(text, width=80*args)

        text.split("\n").collect do |line|
          line.length > width ? line.gsub(/(.{1,#{width}})(\s+|$)/, "\\1\n").strip : line
        end# * "\n"
      end

      # Wraps +text+ to +width+ characters
      def block(text, width=80)
        word_wrap(text, width).each do |line|
          text line
        end
      end

#      def url(selector)
#        _host ? "#{_host.base}#{selector}" : selector
#      end

      def to_s
        @result
      end

      private
      def add_spacing
        br(@spacing)
      end

#      def _host
#        @_host.host rescue nil
#      end
    end
  end
end

# # Render text files
    # class TextContext < RenderContext
    #   def link(txt, *args)
    #     text "#{txt}"
    #   end

    #   def menu(txt, *args)
    #     text "#{txt}"
    #   end

    #   def search(*args); end
    #   alias input search

    #   def text(text)
    #     self << text
    #     self << "\n"
    #   end
    # end


#  end
#end
