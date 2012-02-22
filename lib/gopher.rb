require 'logger'
require 'eventmachine'
require 'stringio'

module Gopher
  require "gopher/version"

  require "gopher/errors"
  require 'gopher/routing'
  require 'gopher/helpers'
  require 'gopher/dispatching'

  require 'gopher/rendering'
  require 'gopher/rendering/base'
  require 'gopher/rendering/menu'

  require 'gopher/request'
  require 'gopher/response'
  require 'gopher/dsl'

  require 'gopher/connection'
  require 'gopher/application'

  require 'gopher/handlers/base_handler'
  require 'gopher/handlers/directory_handler'

  require 'gopher/server'
end

#include Gopher::DSL
