class Job
  def self.enqueue(klass, namespace=:default, options)
    uuid = klass.create(options)
    Resque.redis.sadd("jobs:#{namespace}", uuid) if uuid
  end

  def self.get(uuid)
    Resque::Plugins::Status::Hash.get(uuid)
  end

  def self.remove(uuid, namespace=:default)
    Resque.redis.srem("jobs:#{namespace}", uuid)
  end

  def self.purge(uuid)
    Resque.redis.del("status:#{uuid}")
  end

  def self.clear(namespace=:default)
    Resque.redis.smembers("jobs:#{namespace}").each do |job|
      puts self.get(job).status == 'completed'
      puts job
      self.remove(job, namespace) if self.get(job).status == 'completed'
    end
  end

  def self.jobs(namespace=:default)
    Resque.redis.smembers("jobs:#{namespace}")
  end
end