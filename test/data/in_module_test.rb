require "test/unit"

module InModule
  class SimpleTest < Test::Unit::TestCase
    def test_simple
      assert true
    end

    def test_failed
      assert false
    end
  end
end
