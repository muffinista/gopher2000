require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

require 'bundler/setup'
Bundler.require

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
