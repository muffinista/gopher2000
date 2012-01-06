module Gopher
  module Rendering
    def find_template(t)
#      puts "*** #{t}"
#      puts @templates.inspect
      @menus[t]
    end

    # Find the right template (with context) and instance_exec it inside the context
    def render(template, *arguments)
      #
      # find the right renderer we need
      #
      block, context = find_template(template)

      ctx = Gopher::Rendering::Menu.new

      #     puts block.inspect
 #     ctx = context.new(self)
      ctx.instance_exec(*arguments, &block)
    end

  end
end
