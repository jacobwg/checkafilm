require "bundler/capistrano"  # automatically bundle on deploy
require 'capistrano_colors'   # colorize output

# for rbenv
set :bundle_flags, "--deployment --quiet --binstubs --shebang ruby-local-exec"

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

namespace :environment do
  desc "Symlink the .env file from shared"
  task :symlink, :roles => :app do
    run "ln -sfv #{shared_path}/env #{current_path}/.env"
  end
end

before 'deploy:restart', 'environment:symlink'

# Using foreman for extra processes

namespace :foreman do
  desc "Start the application services"
  task :start, :roles => :app do
    sudo "start #{application}"
  end

  desc "Stop the application services"
  task :stop, :roles => :app do
    sudo "stop #{application}"
  end

  desc "Restart the application services"
  task :restart, :roles => :app do
    run "#{try_sudo} start #{application} || #{try_sudo} restart #{application}"
  end

  desc "Display logs for a certain process - arg example: PROCESS=web-1"
  task :logs, :roles => :app do
    run "cd #{current_path}/log && cat #{ENV["PROCESS"]}.log"
  end

  desc "Export the Procfile to upstart scripts"
  task :export, :roles => :app do
    run "cd #{release_path} && #{try_sudo} foreman export upstart /etc/init -a #{application} -u #{user} -l #{shared_path}/log -p #{base_port}"
  end
end

after 'deploy:update', 'foreman:export'
after 'deploy:update', 'foreman:restart'

