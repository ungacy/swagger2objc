require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :make

desc "Build and install"
task :make do
  `gem build "swagger2objc.gemspec"`
  `gem install "./swagger2objc-0.1.0.gem"`
end
