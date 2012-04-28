worker_processes 3 # amount of unicorn workers to spin up
timeout 30         # restarts workers that hang for 30 seconds
preload_app true   # require for New Relic to work

after_fork do |server, worker|
  Rails.cache.reset if Rails.cache.respond_to?(:reset)

  # if using Session store
  # ObjectSpace.each_object(ActionDispatch::Session::DalliStore) { |obj| obj.reset }

  ActiveRecord::Base.establish_connection

  Sidekiq.configure_client do |config|
    require 'sidekiq/middleware/client/unique_jobs'
    config.client_middleware do |chain|
      chain.add Sidekiq::Middleware::Client::UniqueJobs
    end
  end
end
