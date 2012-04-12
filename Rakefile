require 'bundler'
Bundler.setup :default, :test, :development

require "bundler/gem_tasks"
require 'rdoc/task'

require "gopher2000/version"

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov_opts = %w{--exclude .bundler,.rvm}
  spec.rcov = true
end

task :default => :spec

Bundler::GemHelper.install_tasks

begin
  require 'yard'
  YARD_OPTS = ['-m', 'markdown', '-M', 'redcarpet']
  DOC_FILES = ['lib/**/*.rb', 'README.markdown']

  YARD::Rake::YardocTask.new(:doc) do |t|
    t.files   = DOC_FILES
    #t.options = YARD_OPTS

    puts t.inspect
  end
rescue LoadError
  puts "You need to install YARD."
end
