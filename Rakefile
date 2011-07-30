
task :default => [:test, :integration_test]

require 'echoe'

Echoe.new('qutest', '0.0.1') do |p|
  p.description     = "Qutest publish & run tests through a queue system."
  p.url             = "https://github.com/xli/qutest"
  p.author          = "Li Xiao"
  p.email           = "swing1979@gmail.com"
  p.ignore_pattern  = "*.gemspec"
  p.runtime_dependencies = ["memcache-client"]
  p.test_pattern = 'test/*_test.rb'
  p.ignore_pattern = 'test/integration/vendor/**/*'
  p.rcov_options = '-x "gems"'
  p.rdoc_options    = %w(--main README.rdoc --inline-source --line-numbers --charset UTF-8)
end

Rake::TestTask.new(:integration_test) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/integration/*_test.rb']
  t.warning = true
  t.verbose = false
end
