require 'rubygems'
require 'memcache'
require 'qutest'

KESTREL_SERVER = ENV['KESTREL_SERVER'] || 'localhost:22133'
puts "Qutest connects to kestrel server: #{KESTREL_SERVER}"
Qutest.kestrel = MemCache.new KESTREL_SERVER

namespace :qutest do
  namespace :kestrel do
    desc %{publish tests to queue[queue_name,files_pattern]}
    task :enqueue, :queue_name, :files_pattern do |task, args|
      Qutest.kestrel_queue(args[:queue_name]) << Dir[args[:files_pattern]].tap{|files| puts "enqueuing #{files.join(', ')}"}
    end

    desc %{run test in queue[queue_name,files_pattern]}
    task :test, :queue_name, :files_pattern do |task, args|
      Dir[args[:files_pattern]].each { |f| require f }
      Qutest.run(Qutest.kestrel_queue(args[:queue_name]))
    end

    desc 'checkout kestrel stats'
    task :stats do
      require 'pp'
      pp Qutest.kestrel.stats
    end

    desc 'checkout kestrel dump stats'
    task :dump_stats do
      Qutest::Kestrel::MemCacheExt.bind
      Qutest.kestrel.dump_stats.each do |server, stats|
        puts "#{server} => #{stats}"
      end
    end
  end
end
