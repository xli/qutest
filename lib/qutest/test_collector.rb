require 'test/unit/collector/objectspace'
require 'test/unit/testcase'

module Qutest
  class TestCollector
    def collect(name)
      if defined?(Test::Unit) && Test::Unit.respond_to?(:run=)
        Test::Unit.run = true
      end
      encode suite(name)
    end

    def decode(test)
      return if test.nil?
      class_name, method_name = test.split('#')
      eval("#{class_name}", TOPLEVEL_BINDING).new(method_name)
    end

    private
    def suite(name)
      test_collector.collect(name)
    end

    def test_collector
      Test::Unit::Collector::ObjectSpace.new
    end

    def encode(suite)
      case suite
      when Test::Unit::TestSuite
        suite.tests.collect {|t| encode(t)}.flatten
      when Test::Unit::TestCase
        "#{suite.class.name}##{suite.method_name}"
      else
        raise "Unexpected test: #{suite.inspect}"
      end
    end
  end
end
