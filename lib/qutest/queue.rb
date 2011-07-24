module Qutest

  # The adapter between test frameworks and origin queue.
  # The origin queue object interface:
  #   pop            => return nil or the object in the queue
  #   push(message)  => push a message in queue
  # The framework interface:
  #   tests(name)    => return a list of test dump that can be push into origin queue
  class Queue < Struct.new(:origin, :framework)
    # Enqueue tests loaded from given list files
    def <<(files)
      tests_from(files).each do |test|
        self.origin.push test
      end
    end
    alias :push :<<

    # Dequeue test from origin
    def pop
      self.origin.pop
    end

    def to_s
      "Queue[#{origin}]"
    end

    private
    def tests_from(files)
      before_load_files_tests = framework.tests('before Qutest load files')
      load_tests(files)
      framework.tests('after Qutest load files') - before_load_files_tests
    end

    def load_tests(files)
      files.each do |file|
        load file
      end
    end
  end
end
