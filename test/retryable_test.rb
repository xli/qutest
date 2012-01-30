require File.join(File.dirname(__FILE__), "test_helper")

require "qutest/retryable"

class RetryableTest < Test::Unit::TestCase
  def retry_this(pp)
    if @n != pp
      @n += 1
      raise "retry"
    end
  end

  retryable :retry_this, {:tries => 3}

  def test_retry_actions
    @n = -1
    retry_this(1)
    assert_equal 1, @n
  end

  def test_retry_action_options
    @n = -1
    assert_raise RuntimeError do
      retry_this(2)
    end
    assert_equal 2, @n
  end
end