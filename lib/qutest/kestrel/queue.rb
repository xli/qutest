
module Qutest
  module Kestrel
    class Queue < Struct.new(:name)
      def pop
        Qutest.kestrel.get("#{self.name}/close/open")
      end

      def push(message)
        Qutest.kestrel.set(self.name, message)
      end

      def to_s
        "Kestrel[#{name}]"
      end
    end
  end
end
