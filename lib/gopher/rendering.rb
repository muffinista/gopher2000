module Gopher

  #
  # handle rendering templates for output.  right now, this only handles menu blocks
  #
  module Rendering
    def find_template(t)
      @menus[t]
    end

    # Find the right template (with context) and instance_exec it inside the context
    def render(template, *arguments)
      #
      # find the right renderer we need
      #
      block = find_template(template)
      ctx = Gopher::Rendering::Menu.new

      ctx.instance_exec(*arguments, &block)
    end

  end
end
