require 'test/unit/collector/objectspace'
require 'test/unit/testcase'
require 'test/unit/testsuite'

module Qutest
  module TestUnit
    class TestCollector < Struct.new(:name)
      def collect
        encode suite
      end

      private
      def suite
        test_collector.collect(self.name)
      end

      def test_collector
        Test::Unit::Collector::ObjectSpace.new
      end

      def encode(suite)
        case suite
        when Test::Unit::TestSuite
          suite.tests.collect {|t| encode(t)}.flatten
        when Test::Unit::TestCase
          TestUnit.encode(suite)
        else
          raise "Unexpected test: #{suite.inspect}"
        end
      end
    end
  end
end
