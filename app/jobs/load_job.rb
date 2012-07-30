class LoadJob
  extend Resque::Plugins::LockTimeout

  @queue = :titles
  @lock_timeout = 600 # five minutes

  def self.perform(title_id)
    title = Title.find(title_id)
    title.load! if title
  end

end
