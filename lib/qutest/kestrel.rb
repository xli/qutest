require 'qutest/kestrel/queue'

module Qutest
  module Kestrel
    def kestrel
      @kestrel
    end

    def kestrel=(kestrel)
      @kestrel = kestrel
    end

    def kestrel_queue(name)
      Queue.new(name)
    end
  end
end
