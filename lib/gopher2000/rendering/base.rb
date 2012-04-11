module Gopher
  module Rendering

    # "A CR LF denotes the end of the item." RFC 1436
    # @see http://www.faqs.org/rfcs/rfc1436.html
    LINE_ENDING = "\r\n"

    #
    # base class for rendering output
    #
    class Base < AbstractRenderer
      attr_accessor :result, :spacing, :request, :params, :application

      def initialize(app=nil) # nodoc
        @application = app
        @result = ""
        @spacing = 1
      end

      #
      # add a line to the output
      #
      def <<(string); @result << string.to_s; end

      #
      # Adds +text+ to the result
      #
      def text(text)
        self << text
        add_spacing
      end

      #
      # specify spacing between lines. to make something double-spaced, you could call:
      # spacing(2)
      #
      def spacing(n)
        @spacing = n.to_i
      end

      #
      # Adds +n+ empty lines
      #
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
        end
      end

      # Wraps +text+ to +width+ characters
      def block(text, width=80)

        # this is a hack - recombine lines, then re-split on newlines
        # doing this because word_wrap is returning an array of lines, but
        # those lines have newlines in them where we should wrap
        lines = word_wrap(text, width).join("\n").split("\n")

        lines.each do |line|
          text line.lstrip.rstrip
        end

        self.to_s
      end

      #
      # return the output as a string
      #
      def to_s
        @result
      end

      private
      def add_spacing
        br(@spacing)
      end
    end
  end
end
