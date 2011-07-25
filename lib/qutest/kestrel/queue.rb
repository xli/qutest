
module Qutest
  module Kestrel
    class Queue < Struct.new(:name)
      def pop
        Qutest.kestrel.get("#{self.name}/close/open")
      end

      def push(message)
        Qutest.kestrel.set(self.name, message, hours(24))
      end

      def to_s
        "Kestrel[#{name}]"
      end

      private
      def hours(number)
        number * 60 * 60
      end
    end
  end
end
