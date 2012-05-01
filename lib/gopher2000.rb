require 'eventmachine'
require 'stringio'


#
# Define everything needed to run a gopher server
#
module Gopher
  require "gopher2000/version"
  require "gopher2000/errors"

  require 'gopher2000/rendering/abstract_renderer'
  require 'gopher2000/rendering/base'
  require 'gopher2000/rendering/text'
  require 'gopher2000/rendering/menu'

  require 'gopher2000/request'
  require 'gopher2000/response'

  require 'gopher2000/handlers/base_handler'
  require 'gopher2000/handlers/directory_handler'
  require 'gopher2000/base'
  require 'gopher2000/server'

  require 'gopher2000/dispatcher'
end

#
# include Gopher DSL in the main object space
#
require 'gopher2000/dsl'
include Gopher::DSL
