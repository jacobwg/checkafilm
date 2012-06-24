require "bundler/capistrano"  # automatically bundle on deploy
require 'capistrano_colors'   # colorize output

set :application, "checkafilm"
set :repository,  "https://github.com/jacobwg/checkafilm"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :deploy_via, :remote_cache

set :scm, :git
set :branch, "master"

role :web, "quorra.jacobwg.com"
role :app, "quorra.jacobwg.com"
role :db,  "quorra.jacobwg.com", :primary => true

set :deploy_to, '/home/ruby/checkafilm'

set :base_port, 5000  # should be a multiple of 1000

set :user, 'ruby' # SSH User

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
