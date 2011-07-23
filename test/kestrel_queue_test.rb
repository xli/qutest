require "test/unit"

require File.join(File.dirname(__FILE__), 'kestrel_stub')
require "qutest"

class KestrelQueueTest < Test::Unit::TestCase
  DIR_ROOT = File.dirname(__FILE__)

  def setup
    GC.start
    Qutest.kestrel = KestrelStub.new
  end

  def teardown
    Object.module_eval do
      remove_const(:SimpleTest)
    end
  end

  def test_enqueue
    @queue = Qutest.queue(Qutest.kestrel_queue('name'))
    @queue << Dir["#{DIR_ROOT}/data/simple_test.rb"]
    expected = {'name' => ["SimpleTest#test_failed", "SimpleTest#test_simple"]}
    assert_equal(expected, Qutest.kestrel.store)
  end

  def test_dequeue
    @queue = Qutest.queue(Qutest.kestrel_queue('name'))
    @queue << Dir["#{DIR_ROOT}/data/simple_test.rb"]

    result = Qutest.run(@queue, :name => :embedded)
    assert_equal "2 tests, 2 assertions, 1 failures, 0 errors", result.to_s
  end
end