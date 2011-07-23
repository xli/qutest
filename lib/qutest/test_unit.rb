require 'test/unit/collector/objectspace'

require 'qutest/test_unit/qutest_suite'
require 'qutest/test_unit/embedded_runner'
require 'qutest/test_unit/marshal'

module Qutest
  module TestUnit
    extend Marshal

    def disable_auto_run
      if defined?(Test::Unit) && Test::Unit.respond_to?(:run=)
        Test::Unit.run = true
      end
    end

    def tests(name)
      disable_auto_run
      dump Test::Unit::Collector::ObjectSpace.new.collect(name)
    end

    def run(queue, runner=:console)
      disable_auto_run
      self[runner].run(QutestSuite.new(queue))
    end

    def [](runner)
      case runner.to_s
      when 'console'
        Test::Unit::UI::Console::TestRunner
      when 'embedded'
        EmbeddedRunner
      else
        raise "Unsupported runner: #{runner.inspect}"
      end
    end

    extend self
  end
end
