require 'qutest/test_unit/test_collector'
require 'qutest/test_unit/qutest_suite'
require 'qutest/test_unit/embedded_runner'

module Qutest
  module TestUnit
    def disable_auto_run
      if defined?(Test::Unit) && Test::Unit.respond_to?(:run=)
        Test::Unit.run = true
      end
    end

    def tests(name)
      disable_auto_run
      TestCollector.new(name).collect
    end

    def encode(test)
      "#{test.class.name}##{test.method_name}"
    end

    def decode(test)
      return if test.nil?
      class_name, method_name = test.split('#')
      eval("#{class_name}", TOPLEVEL_BINDING).new(method_name)
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
