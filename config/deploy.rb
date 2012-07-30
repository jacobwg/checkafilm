require 'bundler/capistrano'

set :application, 'checkafilm'

set :scm, :git
set :repository,  'git@github.com:jacobwg/checkafilm.git'
set :deploy_via, :remote_cache
set :branch, 'master'

role :web, 'app.checkafilm.com'
role :app, 'app.checkafilm.com'
role :db,  'app.checkafilm.com', :primary => true

role :resque_worker, 'app.checkafilm.com'

set :user, 'www-data'
set :deploy_to, '/data/apps/checkafilm'

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

before 'deploy:finalize_update', 'deploy:symlink_db'
before 'deploy:finalize_update', 'deploy:symlink_settings'

namespace :deploy do
  desc 'Symlinks the database.yml'
  task :symlink_db, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
  end

  desc 'Symlinks the application.yml'
  task :symlink_settings, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/config/application.yml #{release_path}/config/application.yml"
  end
end

after :deploy, 'deploy:reload_god_config'

set :rails_env, :production
set :unicorn_binary, "/usr/local/bin/unicorn"
set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "/tmp/checkafilm.pid"

namespace :deploy do
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && #{try_sudo} #{unicorn_binary} -c #{unicorn_config} -E #{rails_env} -D"
  end
  task :stop, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill `cat #{unicorn_pid}`"
  end
  task :graceful_stop, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill -s QUIT `cat #{unicorn_pid}`"
  end
  task :reload, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill -s USR2 `cat #{unicorn_pid}`"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    stop
    start
  end

  task :reload_god_config do
    stop_god
    start_god
  end

  task :stop_god do
    run "#{try_sudo} god stop #{application}-resque"
  end

  task :start_god do
    run "#{try_sudo} god start #{application}-resque"
  end
end

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end