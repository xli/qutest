require 'qutest/test_unit/qutest_suite'
require 'qutest/test_unit/embedded_runner'
require 'qutest/test_unit/marshal'

module Qutest
  module TestUnit

    RUNNERS = {
      :console => 'Test::Unit::UI::Console::TestRunner',
      :embedded => 'EmbeddedRunner'
    }

    def disable_auto_run
      if defined?(Test::Unit) && Test::Unit.respond_to?(:run=)
        Test::Unit.run = true
      end
    end

    def tests(name)
      require 'test/unit/collector/objectspace'
      disable_auto_run
      Marshal.dump Test::Unit::Collector::ObjectSpace.new.collect(name)
    end

    def run(queue, runner_name=:console)
      #lazy load testrunner to avoid auto run test at exit
      require 'test/unit/ui/console/testrunner'
      disable_auto_run
      eval(RUNNERS[runner_name]).run(QutestSuite.new(queue))
    end

    module_function :disable_auto_run, :tests, :run
  end
end
