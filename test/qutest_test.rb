require "test/unit"

require "qutest"

class QutestTest < Test::Unit::TestCase
  DIR_ROOT = File.dirname(__FILE__)

  def setup
    GC.start
    @origin = []
    @queue = Qutest.queue(@origin)
  end

  def teardown
    Object.module_eval do
      remove_const(:InModule)
      remove_const(:SimpleTest)
    end
  end

  def test_put_all_tests_in_queue
    @queue << "#{DIR_ROOT}/data/*_test.rb"
    expected = [
      "InModule::SimpleTest#test_failed",
      "InModule::SimpleTest#test_simple",
      "SimpleTest#test_failed",
      "SimpleTest#test_simple"
    ]
    assert_equal expected, @origin
  end

  def test_put_tests_in_queue_should_disable_auto_run
    Test::Unit.run = false
    @queue << "#{DIR_ROOT}/data/*_test.rb"
    assert Test::Unit.run?
  end

  def test_run_tests_in_queue
    @queue << "#{DIR_ROOT}/data/*_test.rb"
    result = Test::Unit::TestResult.new
    @queue.suite.run(result) {}
    assert_equal [], @origin
    assert_equal "4 tests, 4 assertions, 2 failures, 0 errors", result.to_s
  end
end
