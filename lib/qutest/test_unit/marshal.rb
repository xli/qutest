require 'test/unit/testcase'
require 'test/unit/testsuite'

module Qutest
  module TestUnit
    module Marshal
      # dump a suite to an array of string test case
      # dump a test case to a string
      def dump(suite)
        case suite
        when Test::Unit::TestSuite
          suite.tests.collect {|t| dump(t)}.flatten
        when Test::Unit::TestCase
          "#{suite.class.name}##{suite.method_name}"
        else
          raise "Unexpected test: #{suite.inspect}"
        end
      end

      # load a test dump string data in source into a TestCase object
      def load(test)
        class_name, method_name = test.split('#')
        eval("#{class_name}", TOPLEVEL_BINDING).new(method_name)
      end

      extend self
    end
  end
end
