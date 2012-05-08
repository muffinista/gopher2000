module Gopher

  #
  # namespace for classes that render output for the app
  #
  module Rendering

	require 'artii'

    # "A CR LF denotes the end of the item." RFC 1436
    # @see http://www.faqs.org/rfcs/rfc1436.html
    LINE_ENDING = "\r\n"

    #
    # base class for rendering output. this class provides methods
    # that can be used when rendering both text and gopher menus
    #
    class Base < AbstractRenderer
      attr_accessor :result, :spacing, :width, :request, :params, :application

      def initialize(app=nil)
        @application = app
        @result = ""
        @spacing = 1

        # default to 70 per RFC1436 3.9
        # "the user display string should be kept under 70 characters in length"
        @width = 70
      end

      #
      # add a line to the output
      # @param [String] string text to add to the output
      #
      def <<(string)
        @result << string.to_s
      end

      #
      # Adds +text+ to the result
      # @param[String] text text to add to the result. Adds the line,
      #   then adds any required spacing
      #
      def text(text)
        self << text
        add_spacing
      end

      #
      # specify the desired width of text output -- defaults to 70 chars
      # @param [Integer] n desired width for text output
      #
      def width(n)
        @width = n.to_i
      end

      #
      # specify spacing between lines.
      #
      # @param [Integer] n desired line spacing
      #
      # @example to make something double-spaced, you could call:
      #   spacing(2)
      #
      def spacing(n)
        @spacing = n.to_i
      end

      #
      # Add some empty lines to the output
      # @param [Integer] n how many lines to add
      #
      def br(n=1)
        self << (LINE_ENDING * n)
      end

      #
      # wrap +text+ into lines no wider than +width+. Hacked from ActionView
      # @see https://github.com/rails/rails/blob/196407c54f0736c275d2ad4e6f8b0ac55360ad95/actionpack/lib/action_view/helpers/text_helper.rb#L217
      #
      # @param [String] text the text you want to wrap
      # @param [Integer] width the desired width of the block -- defaults to the
      #   current output width
      #
      def block(text, width=@width)

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
	  # output a figlet, which is a big ASCII art header like this:
	  #    _    _      _ _       _
	  #   | |  | |    | | |     | |
	  #   | |__| | ___| | | ___ | |
	  #   |  __  |/ _ \ | |/ _ \| |
	  #   | |  | |  __/ | | (_) |_|
	  #   |_|  |_|\___|_|_|\___/(_)
	  #
	  # This method doesn't do any width checks, so you should be
	  # careful with it.
	  # You can get a list of fonts from the artii source code or
	  # http://www.figlet.org/examples.html
	  # https://github.com/miketierney/artii/tree/master/lib/figlet/fonts

	  # @param [String] str the text you want to use for your figlet
	  # @param [String] font name of the font. Defaults to 'big'.
	  #
	  def figlet(str, font = 'big')
		a = Artii::Base.new(:font => font)
		a.asciify(str).split("\n").each do |l|
		  text l
		end
		self.to_s
	  end

      #
      # output a centered string with a nice underline below it,
      # centered on the current output width
      #
      # @param [String] str - the string to output
      # @param [String] under - the desired underline character
      # @param [Boolean] edge - should we output an edge? if so, there will be a
      #  character to the left/right edges of the string, so you can
      #  draw a box around the text
      #
      def header(str, under = '=', edge = false)
        w = @width
        if edge
          w -= 2
        end

        tmp = str.center(w)
        if edge
          tmp = "#{under}#{tmp}#{under}"
        end

        text(tmp)
        underline(@width, under)
      end

	  #
	  # output a 'small' header, just the text with an underline
      # @param [String] str - the string to output
      # @param [String] under - the desired underline character
	  #
	  def small_header(str, under = '=')
		str = " " + str + " "
		text(str)
		underline(str.length, under)
	  end

      #
      # output a centered string in a box
      # @param [String] str the string to output
      # @param [Strnig] under the character to use to make the box
      #
      def big_header(str, under = '=')
        br
        underline(@width, under)
        header(str, under, true)

        # enforcing some extra space around headers for now
        br
      end

      #
      # output an underline
      #
      # @param [Integer] length the length of the underline -- defaults to current
      #   output width.
      # @param [String] char the character to output
      #
      def underline(length=@width, char='=')
        text(char * length)
      end


      #
      # return the output as a string
      # @return rendered output
      #
      def to_s
        @result
      end

      protected
      #
      # borrowed and modified from ActionView -- wrap text at specified width
      # returning an array of lines for now in case we want to do nifty processing with them
      #
      # File actionpack/lib/action_view/helpers/text_helper.rb, line 217
      def word_wrap(text, width=70*args)
        text.split("\n").collect do |line|
          line.length > width ? line.gsub(/(.{1,#{width}})(\s+|$)/, "\\1\n").strip : line
        end
      end

      private
      def add_spacing
        br(@spacing)
      end
    end
  end
end
