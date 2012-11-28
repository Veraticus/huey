require 'rake/testtask'
require 'yard'

YARD::Rake::YardocTask.new

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
end

desc "Run tests"
task :default => :test