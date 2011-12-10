module Gopher
  class Base
    attr_accessor :routes, :templates

    def initialize
      reset!
    end

    def reset!
      @routes = []
#      if superclass.respond_to?(:templates)
#        @templates = Hash.new { |hash,key| superclass.templates[key] }
#      else
        @templates = {}
#      end
    end

    # Sets an option to the given value.  If the value is a proc,
    # the proc will be called every time the option is accessed.
    def set(option, value = (not_set = true), ignore_setter = false, &block)
      raise ArgumentError if block and !not_set
      value, not_set = block, false if block

      if not_set
        raise ArgumentError unless option.respond_to?(:each)
        option.each { |k,v| set(k, v) }
        return self
      end

      if respond_to?("#{option}=") and not ignore_setter
        return __send__("#{option}=", value)
      end

      setter = proc { |val| set option, val, true }
      getter = proc { value }

      case value
      when Proc
        getter = value
      when Symbol, Fixnum, FalseClass, TrueClass, NilClass
        # we have a lot of enable and disable calls, let's optimize those
        class_eval "def self.#{option}() #{value.inspect} end"
        getter = nil
      when Hash
        setter = proc do |val|
          val = value.merge val if Hash === val
          set option, val, true
        end
      end

      (class << self; self; end).class_eval do
        define_method("#{option}=", &setter) if setter
        define_method(option,       &getter) if getter
        unless method_defined? "#{option}?"
          class_eval "def #{option}?() !!#{option} end"
        end
      end
      self
    end

  end
end
