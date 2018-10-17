require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :make

desc 'Build and install'
task :make do
  `rubocop -a`
  `gem build "swagger2objc.gemspec"`
  `gem install "./swagger2objc-*.gem"`
end
