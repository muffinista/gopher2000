module Gopher
  module Helpers
    def helpers(&block)
      Gopher::Rendering::RenderContext.class_eval(&block)
    end
  end
end