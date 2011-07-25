
class KestrelStub
  attr_reader :store

  def initialize
    @store = Hash.new {|h, k| h[k] = []}
  end

  def set(key, value, expiry = 0, raw = false) #expiry seconds
    queue_name, cmds = parse(key)
    raise "Should not follow flags" if cmds.any?
    raise "Should be expired after 6 hours" if hours(6) > expiry
    @store[queue_name] << value
  end

  def get(key, raw = false)
    queue_name, cmds = parse(key)
    raise "Must follow flags: close/open" if cmds != ['close', 'open']
    @store[queue_name].pop
  end

  private
  def hours(number)
    number * 60 * 60
  end

  def parse(key)
    cmds = key.split('/')
    queue_name = cmds.shift
    [queue_name, cmds]
  end
end
