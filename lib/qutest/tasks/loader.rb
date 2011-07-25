#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

require 'rubygems'
require 'memcache'
require 'qutest'
require 'qutest/tasks/kestrel'

module Qutest
  module Tasks
    class Kestrel
      module Loader
        def execute
          puts "Qutest connects to kestrel server: #{server}"
          Qutest.kestrel = MemCache.new server

          case name
          when 'enqueue'
            start = Time.now
            Qutest.kestrel_queue(queue_name).push files do |total, index, test|
              if index == 0
                puts "Total: #{total}"
              end
              print '.'
            end
            puts "\nDone: #{Time.now - start} seconds"
          when 'test'
            files.each { |f| require f }
            Qutest.run(Qutest.kestrel_queue(queue_name))
          when 'stats'
            require 'pp'
            pp Qutest.kestrel.stats
          when 'dump_stats'
            Qutest::Kestrel::MemCacheExt.bind
            Qutest.kestrel.dump_stats.each do |server, stats|
              puts "#{server} => #{stats}"
            end
          else
            raise "Unsupported command: #{cmd.inspect}"
          end
        end
      end
    end
  end
end

Qutest::Tasks::Kestrel::Command.send(:include, Qutest::Tasks::Kestrel::Loader)
Qutest::Tasks::Kestrel::Command.parse(ARGV).execute