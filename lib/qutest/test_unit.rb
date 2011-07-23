require 'test/unit/collector/objectspace'
require 'test/unit/ui/console/testrunner'

require 'qutest/test_unit/qutest_suite'
require 'qutest/test_unit/embedded_runner'
require 'qutest/test_unit/marshal'

module Qutest
  module TestUnit

    RUNNERS = {
      :console => Test::Unit::UI::Console::TestRunner,
      :embedded => EmbeddedRunner
    }

    def disable_auto_run
      if defined?(Test::Unit) && Test::Unit.respond_to?(:run=)
        Test::Unit.run = true
      end
    end

    def tests(name)
      disable_auto_run
      Marshal.dump Test::Unit::Collector::ObjectSpace.new.collect(name)
    end

    def run(queue, runner_name=:console)
      disable_auto_run
      RUNNERS[runner_name].run(QutestSuite.new(queue))
    end

    module_function :disable_auto_run, :tests, :run
  end
end
