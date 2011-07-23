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
    @queue.push "#{DIR_ROOT}/data/tests/*_test.rb"
    expected = [
      "InModule::SimpleTest#test_failed",
      "InModule::SimpleTest#test_simple",
      "SimpleTest#test_failed",
      "SimpleTest#test_simple",
      "AnotherTest#test_another"
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
    result = Qutest.run(@queue, :name => :embedded)
    assert_equal [], @origin
    assert_equal "4 tests, 4 assertions, 2 failures, 0 errors", result.to_s
  end

  def test_should_mark_test_unit_run_after_run_tests
    @queue << "#{DIR_ROOT}/data/*_test.rb"
    Test::Unit.run = false
    result = Qutest.run(@queue, :name => :embedded)
    assert Test::Unit.run?
  end
end
