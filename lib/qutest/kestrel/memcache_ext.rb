
module Qutest
  module Kestrel
    module MemCacheExt
      def self.bind
        case MemCache::VERSION
        when '1.8.5'
          MemCache.send(:include, V185)
        when '1.5.0'
          MemCache.send(:include, V150)
        else
          puts "WARNING: MemCache #{MemCache::VERSION} is not supported with dump_stats (only 1.8.5 and 1.5.0 get dump_stats support)"
        end
      end
      module V150
        def dump_stats
          raise ::MemCache::MemCacheError, "No active servers" unless active?
          server_stats = {}

          @servers.each do |server|
            sock = server.socket
            raise ::MemCache::MemCacheError, "No connection to server" if sock.nil?

            value = nil
            begin
              sock.write "stats\r\n"
              stats = ""
              while line = sock.gets do
                break if line == "END\r\n"
                stats << line
              end
              server_stats["#{server.host}:#{server.port}"] = stats
            rescue SocketError, SystemCallError, IOError => err
              server.close
              raise ::MemCache::MemCacheError, err.message
            end
          end

          server_stats
        end
      end
      module V185
        def dump_stats
          raise ::MemCache::MemCacheError, "No active servers" unless active?
          server_stats = {}

          @servers.each do |server|
            next unless server.alive?

            with_socket_management(server) do |socket|
              value = nil
              socket.write "dump_stats\r\n"
              stats = ""
              while line = socket.gets do
                raise_on_error_response! line
                break if line == "END\r\n"
                stats << line
              end
              server_stats["#{server.host}:#{server.port}"] = stats
            end
          end

          raise ::MemCache::MemCacheError, "No active servers" if server_stats.empty?
          server_stats
        end
      end
    end
  end
end
