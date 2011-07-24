require 'qutest/test_unit/marshal'

module Qutest
  module TestUnit

    # Adapter of Qutest::Queue and Test::Unit::TestCase
    class QutestSuite < Struct.new(:queue)
      def run(result, &progress_block)
        while(test = queue.pop) do
          Marshal.load(test).run(result, &progress_block)
        end
      end

      def to_s
        "QutestSuite from #{queue}"
      end
    end
  end
end
