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

  def test_integrated_with_unit_test_and_kestrel
    Dir.chdir(File.join(TEST_DIR, 'data')) do
      output = %x[rake enqueue]
      assert_equal(0, $?.exitstatus, output)
      assert_match(/^4 tests, 4 assertions, 2 failures, 0 errors$/m, %x[rake test])
    end
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
