module Gopher
  module Rendering
    # All rendering of templates (inline and otherwise) is done inside a RenderContext
    class RenderContext
      attr_accessor :result

      def initialize(host=nil) # nodoc
        @_host = host
        @result = ""
      end

      def <<(string); @result << string.to_s; end

      # Adds +text+ to the result
      def text(text); self << text; end

      # Adds +n+ empty lines
      def br(n=1); n.times { text '' } end

      # Wraps +text+ to +width+ characters
      def block(text, width=80)
        text.each_line do |line|
          line.wrap(width) { |chunk| text chunk.rstrip }
        end
      end

      # Experimental! No specs! Ayeee!
      def partial(partial, *args)
        args.flatten!
        partial = @_host.find_partial(partial)
        if args.empty?
          self.instance_exec(*args, &partial)
        else
          args.each do |a|
            self.instance_exec(a, &partial)
          end
        end
      end

      def url(selector)
        _host ? "#{_host.base}#{selector}" : selector
      end

      private
      def _host
        @_host.host rescue nil
      end
    end

    # Render text files
    class TextContext < RenderContext
      def link(txt, *args)
        text "#{txt}"
      end

      def menu(txt, *args)
        text "#{txt}"
      end

      def search(*args); end
      alias input search

      def text(text)
        self << text
        self << "\n"
      end
    end

    # The MenuContext is for rendering gopher menus
    class MenuContext < RenderContext

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
      def line(type, text, selector, host=Gopher::Server.host, port=Gopher::Server.port)
        text = sanitize_text(text)

        self << ["#{type}#{text}", selector, host, port].join("\t")
        self << "\r\n" # End the gopher line
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

    # Find the right template (with context) and instance_exec it inside the context
    def render(template, *arguments)
      block, context = find_template(template)
      ctx = context.new(self)
      ctx.instance_exec(*arguments, &block)
      ctx.result
    end
  end
end
