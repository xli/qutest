module Qutest

  # The adapter between test frameworks and origin queue.
  class Queue < Struct.new(:origin, :framework)
    def <<(files)
      tests_from(files).each do |test|
        self.origin.push test
      end
    end
    alias :push :<<

    def pop
      framework.decode(self.origin.pop)
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
