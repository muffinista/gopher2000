module Gopher
  module Helpers
    #
    # Add helpers to the Application class, which allows them to be called
    # when outputting the results of an action. Here's the code in Sinatra for reference:
    #
    # Makes the methods defined in the block and in the Modules given
    # in `extensions` available to the handlers and templates
    #  def helpers(*extensions, &block)
    #    class_eval(&block)   if block_given?
    #    include(*extensions) if extensions.any?
    #  end
    #
    # target - What class should receive the helpers -- defaults to Gopher::Application, which will make it generally available
    # block -- a block which declares the helpers you want. for example:
    #
    # helpers do
    #  def foo; "FOO"; end
    # end
    def helpers(target=Gopher::Application, &block)
      target.class_eval(&block)
    end
  end
end
