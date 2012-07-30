# listen on both a Unix domain socket and a TCP port,
# we use a shorter backlog for quicker failover when busy
listen "/tmp/checkafilm.sock", :backlog => 64
listen 4040, :tcp_nopush => true

worker_processes 3 # amount of unicorn workers to spin up
timeout 30         # restarts workers that hang for 30 seconds
preload_app true   # require for New Relic to work

pid '/tmp/checkafilm.pid'

after_fork do |server, worker|
  Rails.cache.reset if Rails.cache.respond_to?(:reset)

  # if using Session store
  # ObjectSpace.each_object(ActionDispatch::Session::DalliStore) { |obj| obj.reset }

  ActiveRecord::Base.establish_connection
end