require 'resque/plugins/lock'

class LoadJob
  extend Resque::Plugins::Lock
  include Resque::Plugins::Status

  @queue = :titles

  def perform
    title = Title.find(options['id'])
    at(1, 2, "At 1 of 2")
    title.load! if title
    at(2, 2, "At 2 of 2")
  end

  def self.lock(uuid, options = {})
    "lock:#{name}-#{options.to_s}"
  end

end
