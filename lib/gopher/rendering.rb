module Gopher
  #
  # handle rendering templates for output.  right now, this only handles menu blocks
  #
  module Rendering
    def menu(name, &block)
      @menus ||= {}
      @menus[name.to_sym] = block
    end

    def not_found(&block)
      menu :not_found, &block
    end

    # def template(name, &block)
    #   @templates ||= {}
    #   @templates[name.to_sym] = block
    # end

    def find_template(t)
      @menus[t]
    end

    # Find the right template (with context) and instance_exec it inside the context
    def render(template, *arguments)
      #
      # find the right renderer we need
      #
      block = find_template(template)

      raise TemplateNotFound if block.nil?

      ctx = Gopher::Rendering::Menu.new
      ctx.params = @params
      ctx.request = @request

      ctx.instance_exec(*arguments, &block)
    end

    def not_found_template
      @menus.include?(:not_found) ? :not_found : :'internal/not_found'
    end

    def register_defaults
      menu :'internal/not_found' do
        text "Sorry, #{@request.selector} was not found"
      end
    end

  end
end
