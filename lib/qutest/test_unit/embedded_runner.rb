require 'test/unit/testresult'

module Qutest
  module TestUnit
    # Provides a way to run suite in memory
    class EmbeddedRunner
      def self.run(suite, *args)
        result = Test::Unit::TestResult.new
        suite.run(result) do |channel, value|
          #who cares?
        end
        result
      end
    end
  end
end
