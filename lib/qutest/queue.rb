module Qutest

  # The adapter between test frameworks and origin queue.
  # The origin queue object interface:
  #   pop            => return nil or the object in the queue
  #   push(message)  => push a message in queue
  class Queue < Struct.new(:origin, :framework)
    def <<(files)
      tests_from(files).each do |test|
        self.origin.push test
      end
    end
    alias :push :<<

    def pop
      self.origin.pop
    end

    private
    def tests_from(files)
      before_load_files_tests = framework.tests('before Qutest load files')
      load_tests(files)
      framework.tests('after Qutest load files') - before_load_files_tests
    end

    def load_tests(files)
      Dir[files].each do |file|
        load file
      end
    end
  end
end
