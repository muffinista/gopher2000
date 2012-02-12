require 'logger'
require 'eventmachine'
require 'stringio'

require "gopher/version"

require "gopher/errors"
require 'gopher/routing'
require 'gopher/templating'
require 'gopher/helpers'
require 'gopher/dispatching'

require 'gopher/rendering'
require 'gopher/rendering/base'
require 'gopher/rendering/menu'

require 'gopher/request'
require 'gopher/response'
require 'gopher/dsl'

require 'gopher/handler'
require 'gopher/connection'
require 'gopher/application'

require 'gopher/handlers/base_handler'
require 'gopher/handlers/directory_handler'

module Gopher

  # # Defines the Gopher server through the +block+
  # def self.server(&block)
  #   Gopher::Server.instance_eval(&block) if block_given?
  # end

#  def self.logger
#    @logger ||= Logger.new('gopher.log')
#  end

#  at_exit { Application.run! if $!.nil? && Application.run? }
end

include Gopher::DSL
