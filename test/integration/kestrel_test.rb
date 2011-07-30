require File.join(File.dirname(__FILE__), '..', "test_helper")
require 'qutest'
require 'rubygems'
require 'memcache'
require 'fileutils'

class IntegrationTest < Test::Unit::TestCase
  def setup
    @kestrel_thread = Thread.start do
      %x[java -jar #{TEST_DIR}/integration/vendor/kestrel/kestrel-1.3.0.jar]
    end
    wait_until_kestrel('Kestrel started.')
    sleep 1
  end

  def teardown
    Qutest::Kestrel::MemCacheExt.bind
    @kestrel_thread.kill
    @memcache = MemCache.new 'localhost:22133'
    @memcache.shutdown
    wait_until_kestrel('Shutting down!')
    FileUtils.rm_rf('kestrel.log')
  end

  def test_tasks_defined_in_rakefile
    within_test_data_dir do
      output = %x[rake -T]
      assert_match(/^rake qutest:enqueue:queue_name/m, output)
      assert_match(/^rake qutest:run_test:queue_name/m, output)
      assert_match(/^rake qutest:dump_stats/m, output)
      assert_match(/^rake qutest:stats/m, output)
    end
  end

  def test_integrated_with_unit_test_and_kestrel
    within_test_data_dir do
      output = %x[rake enqueue]
      assert_equal(0, $?.exitstatus, output)
      assert_match(/^4 tests, 4 assertions, 2 failures, 0 errors$/m, %x[rake test])
    end
  end

  def test_stats
    within_test_data_dir do
      output = %x[rake stats]
      assert_equal(0, $?.exitstatus, output)
      assert_match(/"localhost:22133"=>/m, output)
    end
  end

  def test_dump_stats
    within_test_data_dir do
      output = %x[rake dump_stats]
      assert_equal(0, $?.exitstatus, output)
      assert_match(/localhost:22133 =>/m, output)
    end
  end

  def within_test_data_dir(&block)
    Dir.chdir(File.join(TEST_DIR, 'data'), &block)
  end
  def wait_until_kestrel(target)
    loop do
      if File.exists?('kestrel.log')
        logs = File.read('kestrel.log').strip
        break if logs.split("\n").last =~ /#{target}/
      end
      sleep 0.1
    end
  end
end
