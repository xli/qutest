
module Qutest
  module TestUnit

    # Adapter of Qutest::Queue and Test::Unit::TestCase
    class QutestSuite < Struct.new(:queue)
      def run(result, &progress_block)
        while(test = queue.pop) do
          test.run(result, &progress_block)
        end
      end
    end
  end
end
