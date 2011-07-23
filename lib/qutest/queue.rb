require 'qutest/qutest_suite'

module Qutest
  class Queue < Struct.new(:origin, :test_collector)
    def <<(files)
      tests_from(files).each do |test|
        self.origin.push test
      end
    end

    def pop
      test_collector.decode(self.origin.pop)
    end

    def suite
      QutestSuite.new(self)
    end

    private
    def load_tests(files)
      Dir[files].each do |file|
        load file
      end
    end

    def tests_from(files)
      before_load_files_tests = tests('before Qutest load files')
      load_tests(files)
      tests('after Qutest load files') - before_load_files_tests
    end

    def tests(name)
      test_collector.collect(name)
    end
  end
end
