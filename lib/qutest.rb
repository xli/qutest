
require 'qutest/queue'
require 'qutest/test_collector'

module Qutest
  VERSION = '0.0.1'

  # Wrap a given origin queue as Qutestue (Qutest queue)
  # The origin queue object interface:
  #   pop            => return nil or the object in the queue
  #   push(message)  => push a message in queue
  def self.queue(origin)
    Queue.new(origin, TestCollector.new)
  end
end
