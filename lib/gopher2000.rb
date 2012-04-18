require 'logging'
require 'eventmachine'
require 'stringio'

#
# steal cattr_reader/writer
#
# class Class
#   def cattr_reader(*syms)
#     syms.each do |sym|
#       class_eval(<<-EOS, __FILE__, __LINE__ + 1)
#         unless defined? @@#{sym}
#           @@#{sym} = nil
#         end

#         def self.#{sym}
#           @@#{sym}
#         end
#       EOS

#       class_eval(<<-EOS, __FILE__, __LINE__ + 1)
#           def #{sym}
#             @@#{sym}
#           end
#           EOS
#       end
#   end

#   def cattr_writer(*syms)
#     syms.each do |sym|
#       class_eval(<<-EOS, __FILE__, __LINE__ + 1)
#         unless defined? @@#{sym}
#           @@#{sym} = nil
#         end

#         def self.#{sym}=(obj)
#           @@#{sym} = obj
#         end
#       EOS

#         class_eval(<<-EOS, __FILE__, __LINE__ + 1)
#           def #{sym}=(obj)
#             @@#{sym} = obj
#           end
#         EOS
#       self.send("#{sym}=", yield) if block_given?
#     end
#   end

#   def cattr_accessor(*syms, &blk)
#     cattr_reader(*syms)
#     cattr_writer(*syms, &blk)
#   end
# end



module Gopher
  require "gopher2000/version"
#  require "gopher2000/logging"

  require "gopher2000/errors"
#  require 'gopher2000/routing'
#  require 'gopher2000/helpers'

#  require 'gopher2000/rendering'
  require 'gopher2000/rendering/abstract_renderer'
  require 'gopher2000/rendering/base'
  require 'gopher2000/rendering/text'
  require 'gopher2000/rendering/menu'

#  require 'gopher2000/dispatching'

  require 'gopher2000/request'
  require 'gopher2000/response'

#  require 'gopher2000/application'

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
