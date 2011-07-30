module Qutest
  module Tasks
    class Kestrel < Struct.new(:server, :libs, :tags, :queue_files)
      class Command < Struct.new(:name, :server, :queue_name, :files)
        def self.parse(argv)
          files = (argv[3..-1] || []).inject([]) {|r, pattern| r << Dir[pattern]}.flatten.uniq
          new(argv[0], argv[1], argv[2], files)
        end
      end

      class RakeTasks < Struct.new(:kestrel)
        def define
          namespace :qutest do
            [:enqueue, :run_test].each do |target|
              namespace target do
                kestrel.qutest_queues.each do |queue_name|
                  desc "#{target} #{queue_name}"
                  task queue_name do
                    t = lambda { ruby kestrel.send(target, queue_name) }
                    if block_given?
                      t = yield(queue_name, t)
                    end
                    t.call
                  end
                end
              end
            end

            desc "Show kestrel server stats"
            task :stats do
              ruby kestrel.stats
            end
            desc "Show kestrel server dump_stats"
            task :dump_stats do
              ruby kestrel.dump_stats
            end
          end
        end
      end

      def tag_with(*tags)
        self.tags ||= []
        self.tags.concat(tags)
      end

      def qutest(new_queue_files)
        self.queue_files ||= {}
        self.queue_files.merge! new_queue_files
      end

      def enqueue(queue_name)
        working_on_queue('enqueue', queue_name, self.queue_files[queue_name])
      end

      def run_test(queue_name)
        working_on_queue('run_test', queue_name, self.queue_files[queue_name])
      end

      def stats
        command_script('stats')
      end

      def dump_stats
        command_script('dump_stats')
      end

      def define_tasks(&block)
        RakeTasks.new(self).define(&block)
      end

      def qutest_queues
        queue_files.keys
      end

      private
      def full_queue_name(name)
        [name].concat(self.tags || []).join('_').gsub(/\W/, '_')
      end

      def command_script(cmd)
        script = []
        script << "-I#{lib_path.inspect}" if lib_path
        script << kestrel_loader.inspect
        script << cmd
        script << server.inspect
        script.join(' ')
      end

      def working_on_queue(cmd, queue_name, files)
        script = []
        script << command_script(cmd)
        script << full_queue_name(queue_name).inspect
        script << files.collect{|f| f.to_s.inspect}.join(' ')
        script.join(' ')
      end

      def lib_path
        if self.libs && !self.libs.empty?
          self.libs.join(File::PATH_SEPARATOR)
        end
      end

      def kestrel_loader
        File.expand_path(File.join(File.dirname(__FILE__), 'loader.rb'))
      end
    end
  end
end
