module Gopher
  #
  # handle rendering templates for output.  right now, this only handles menu blocks
  #
  module Rendering
    def menu(name, &block)
      menus[name.to_sym] = block
    end
    def text(name, &block)
      text_templates[name.to_sym] = block
    end

    #
    # specify a template to be used for missing requests
    #
    def not_found(&block)
      menu :not_found, &block
    end

    def find_template(t)
      x = menus[t]
      if x
        return x, Menu
      end
      x = text_templates[t]
      if x
        return x, Text
      end
    end

    # Find the right template (with context) and instance_exec it inside the context
    def render(template, *arguments)
      #
      # find the right renderer we need
      #
      block, handler = find_template(template)

      raise TemplateNotFound if block.nil?

      ctx = handler.new(application)
      ctx.params = @params
      ctx.request = @request

      ctx.instance_exec(*arguments, &block)
    end

    def not_found_template
      menus.include?(:not_found) ? :not_found : :'internal/not_found'
    end

    def error_template
      menus.include?(:error) ? :error : :'internal/error'
    end

    def invalid_request_template
      menus.include?(:invalid_request) ? :invalid_request : :'internal/invalid_request'
    end

    def register_defaults
      menu :'internal/not_found' do
        text "Sorry, #{@request.selector} was not found"
      end

      menu :'internal/error' do |details|
        text "Sorry, there was an error #{details}"
      end

      menu :'internal/invalid_request' do
        text "invalid request"
      end
    end

  end
end
