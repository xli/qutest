require "test/unit"

require "qutest/tasks/kestrel"

class KestrelTaskTest < Test::Unit::TestCase

  def test_enqueue_task_ruby_script
    task = Qutest::Tasks::Kestrel.new('server', ['test'])
    r = task.enqueue('queue_name', ['file1', 'file2'])
    expected = %{-I"test" #{loader_path.inspect} enqueue "server" "queue_name" "file1" "file2"}
    assert_equal expected, r
  end

  def test_test_task_ruby_script
    task = Qutest::Tasks::Kestrel.new('server', ['test'])
    r = task.test('queue_name', ['*_test.rb', 'file2'])
    expected = %{-I"test" #{loader_path.inspect} test "server" "queue_name" "*_test.rb" "file2"}
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
    cmd = task.test('queue_name', ['*_test.rb', 'file2'])
    command = Qutest::Tasks::Kestrel::Command.parse(['test', 'server', 'queue name', '*_test.rb', '*.rb', 'data/*_test.rb'])

    assert_equal 'test', command.name
    assert_equal 'server', command.server
    assert_equal 'queue name', command.queue_name
    files = Dir["*.rb"] + Dir['data/*_test.rb']
    assert_equal files.sort, command.files.sort
  end

  def test_parse_monitor_argv
    task = Qutest::Tasks::Kestrel.new('server', ['test'])
    cmd = task.test('queue_name', ['*_test.rb', 'file2'])
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