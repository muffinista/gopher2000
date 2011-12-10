require "gopher/version"

require 'ext/object'
require 'ext/string'

#require 'jcode'
require 'logger'
require 'eventmachine'
require 'stringio'

require 'gopher/base'

require 'gopher/utils'
# require 'gopher/errors'
# require 'gopher/configuration'
require 'gopher/routing'

# require 'gopher/templating'
# require 'gopher/rendering'
# require 'gopher/dispatching'

# require 'gopher/helpers'

require 'gopher/application'

# #require 'gopher/gophlet'

# require 'gopher/connection'

# require 'gophlets/file_browser'

module Gopher

  # # Defines the Gopher server through the +block+
  # def self.server(&block)
  #   Gopher::Server.instance_eval(&block) if block_given?
  # end

  # def self.logger
  #   @logger ||= Logger.new('gopher.log')
  # end
end
