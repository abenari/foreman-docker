require 'bundler/gem_tasks'

begin
  require 'bundler/setup'
rescue LoadError
  Rails.logger.error 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

task :default => :test
