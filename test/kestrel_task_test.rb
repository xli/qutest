require File.join(File.dirname(__FILE__), "test_helper")

require "qutest/tasks/kestrel"

class KestrelTaskTest < Test::Unit::TestCase

  def test_qutest_multi_queues
    task = Qutest::Tasks::Kestrel.new('server', ['test'])
    task.qutest(:queue1 => ['file1'], :queue2 => ['file2'])
    task.qutest(:queue3 => ['file3'])
    prefix = %{-I"test" #{loader_path.inspect} enqueue "server"}
    assert_equal %{#{prefix} "queue1" "file1"}, task.enqueue(:queue1)
    assert_equal %{#{prefix} "queue2" "file2"}, task.enqueue(:queue2)
    assert_equal %{#{prefix} "queue3" "file3"}, task.enqueue(:queue3)
  end

  def test_tag_queue
    task = Qutest::Tasks::Kestrel.new('server', ['test'])
    task.tag_with 'tag1', '[tag2]'
    task.qutest(:queue_name => ['file1', 'file2'])
    prefix = %{-I"test" #{loader_path.inspect}}

    assert_equal %{#{prefix} enqueue "server" "queue_name_tag1__tag2_" "file1" "file2"}, task.enqueue(:queue_name)
    assert_equal %{#{prefix} run_test "server" "queue_name_tag1__tag2_" "file1" "file2"}, task.run_test(:queue_name)
  end

  def test_enqueue_task_ruby_script
    task = Qutest::Tasks::Kestrel.new('server', ['test'])
    task.qutest(:queue_name => ['file1', 'file2'])
    r = task.enqueue :queue_name
    expected = %{-I"test" #{loader_path.inspect} enqueue "server" "queue_name" "file1" "file2"}
    assert_equal expected, r
  end

  def test_test_task_ruby_script
    task = Qutest::Tasks::Kestrel.new('server', ['test'])
    task.qutest('queue_name' => ['*_test.rb', 'file2'])
    r = task.run_test('queue_name')
    expected = %{-I"test" #{loader_path.inspect} run_test "server" "queue_name" "*_test.rb" "file2"}
    assert_equal expected, r
  end

  def test_stats_task_ruby_script
    task = Qutest::Tasks::Kestrel.new('server')
    r = task.stats
    expected = %{#{loader_path.inspect} stats "server"}
    assert_equal expected, r
  end

  def test_dump_stats_task_ruby_script
    task = Qutest::Tasks::Kestrel.new('server')
    r = task.dump_stats
    expected = %{#{loader_path.inspect} dump_stats "server"}
    assert_equal expected, r
  end

  def test_parse_argv
    task = Qutest::Tasks::Kestrel.new('server', ['test'])
    task.qutest('queue_name' => ['*_test.rb', 'file2'])
    cmd = task.run_test('queue_name')
    command = Qutest::Tasks::Kestrel::Command.parse(['run_test', 'server', 'queue name', '*_test.rb', '*.rb', 'data/*_test.rb'])

    assert_equal 'run_test', command.name
    assert_equal 'server', command.server
    assert_equal 'queue name', command.queue_name
    files = Dir["*.rb"] + Dir['data/*_test.rb']
    assert_equal files.sort, command.files.sort
  end

  def test_parse_monitor_argv
    task = Qutest::Tasks::Kestrel.new('server', ['test'])
    command = Qutest::Tasks::Kestrel::Command.parse(['stats', 'server'])

    assert_equal 'stats', command.name
    assert_equal 'server', command.server
    assert_equal nil, command.queue_name
    assert_equal [], command.files
  end

  def loader_path
    File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'qutest', 'tasks', 'loader.rb'))
  end
end