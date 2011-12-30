module Gopher
  module Templating
    def menu(name, &block)
      @menus ||= {}
      @menus[name.to_sym] = block
    end

    def template(name, &block)
      @templates ||= {}
      @templates[name.to_sym] = block
    end
  end
end
