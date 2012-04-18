module Gopher

  #
  # namespace for custom handlers
  #
  module Handlers
    #
    # Base class for custom request handlers.  Any custom handler
    # code should inherit from this class.
    #
    class BaseHandler
      attr_accessor :application

      # include rendering here so that Menu/Text renderers are available to any handlers
      include Rendering
    end
  end
end
