
require 'qutest/queue'
require 'qutest/test_unit'

module Qutest
  VERSION = '0.0.1'
  DEFAULT_RUNNER = {:framework => :test_unit, :name => :console}
  DEFAULT_FRAMEWORK = :test_unit
  FRAMEWORKS = {:test_unit => TestUnit}

  # Wrap a given origin queue as Qutest queue
  def queue(origin, framework_name=DEFAULT_FRAMEWORK)
    Queue.new(origin, FRAMEWORKS[framework_name])
  end

  # Run inqueue tests by runner
  # DEFAULT_RUNNER is test/unit/ui/runner/console 
  def run(queue, runner={})
    runner = DEFAULT_RUNNER.merge(runner)
    case runner[:framework]
    when :test_unit
      TestUnit.run(queue, runner[:name])
    else
      raise "Unsupported runner: #{runner.inspect}"
    end
  end

  extend self
end
