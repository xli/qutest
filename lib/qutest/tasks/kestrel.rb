
module Qutest
  module Tasks
    class Kestrel < Struct.new(:server, :libs)
      def enqueue(queue_name, files)
        working_on_queue('enqueue', queue_name, files)
      end

      def test(queue_name, files)
        working_on_queue('test', queue_name, files)
      end

      def stats
        command_script('stats')
      end

      def dump_stats
        command_script('dump_stats')
      end

      private
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
        script << queue_name.inspect
        script << files.collect{|f| f.inspect}.join(' ')
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
