require 'qutest/kestrel/queue'
require 'qutest/kestrel/memcache_ext'

module Qutest
  module Kestrel
    attr_accessor :kestrel

    def kestrel_queue(name)
      queue(Queue.new(name))
    end
  end
end
