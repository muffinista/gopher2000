require 'logging'
require 'eventmachine'
require 'stringio'

#
# steal cattr_reader/writer
#
class Class
  def cattr_reader(*syms)
    syms.each do |sym|
      class_eval(<<-EOS, __FILE__, __LINE__ + 1)
        unless defined? @@#{sym}
          @@#{sym} = nil
        end

        def self.#{sym}
          @@#{sym}
        end
      EOS

      class_eval(<<-EOS, __FILE__, __LINE__ + 1)
          def #{sym}
            @@#{sym}
          end
          EOS
      end
  end

  def cattr_writer(*syms)
    syms.each do |sym|
      class_eval(<<-EOS, __FILE__, __LINE__ + 1)
        unless defined? @@#{sym}
          @@#{sym} = nil
        end

        def self.#{sym}=(obj)
          @@#{sym} = obj
        end
      EOS

        class_eval(<<-EOS, __FILE__, __LINE__ + 1)
          def #{sym}=(obj)
            @@#{sym} = obj
          end
        EOS
      self.send("#{sym}=", yield) if block_given?
    end
  end

  def cattr_accessor(*syms, &blk)
    cattr_reader(*syms)
    cattr_writer(*syms, &blk)
  end
end



module Gopher
  require "gopher/version"
  require "gopher/logging"

  require "gopher/errors"
  require 'gopher/routing'
  require 'gopher/helpers'
  require 'gopher/dispatching'

  require 'gopher/rendering'
  require 'gopher/rendering/base'
  require 'gopher/rendering/menu'

  require 'gopher/request'
  require 'gopher/response'
 # require 'gopher/dsl'

  require 'gopher/connection'
  require 'gopher/application'

  require 'gopher/handlers/base_handler'
  require 'gopher/handlers/directory_handler'

  require 'gopher/server'
end


require 'gopher/dsl'
include Gopher::DSL
