module Gopher
  module Rendering
    # All rendering of templates (inline and otherwise) is done inside a RenderContext
    class Base
      attr_accessor :result, :spacing

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
        self << ("\n" * n)
      end

      # Wraps +text+ to +width+ characters
      def block(text, width=80)
        text.each_line do |line|
          line.wrap(width) { |chunk| text chunk.rstrip }
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
