require "test_helper"
require "qutest"

class KestrelQueueTest < Test::Unit::TestCase
  def setup
    GC.start
    Qutest.kestrel = KestrelStub.new
  end

  def teardown
    Object.module_eval do
      remove_const(:SimpleTest) if defined?(SimpleTest)
    end
  end

  def test_enqueue
    Qutest.kestrel_queue('name') << Dir["#{TEST_DIR}/data/simple_test.rb"]

    expected = {'name' => ["SimpleTest#test_failed", "SimpleTest#test_simple"]}
    assert_equal(expected, Qutest.kestrel.store)
  end

  def test_dequeue
    Qutest.kestrel_queue('name') << Dir["#{TEST_DIR}/data/simple_test.rb"]
    result = Qutest.run(Qutest.kestrel_queue('name'), :name => :embedded)

    assert_equal "2 tests, 2 assertions, 1 failures, 0 errors", result.to_s
  end

  def test_pp_to_s
    queue = Qutest.kestrel_queue('queue_name')
    assert_equal "QutestSuite from Queue[Kestrel[queue_name]]", Qutest::TestUnit::QutestSuite.new(queue).to_s
  end
end
