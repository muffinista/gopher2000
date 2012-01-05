module Gopher
  module Helpers
    def helpers(&block)
      Gopher::Rendering::Base.class_eval(&block)
    end
  end
end
