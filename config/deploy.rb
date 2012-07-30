require 'bundler/capistrano'

set :application, 'checkafilm'

set :scm, :git
set :repository,  'git@github.com:jacobwg/checkafilm.git'
set :deploy_via, :remote_cache
set :branch, 'master'

role :web, 'web.checkafilm.com'
role :app, 'app.checkafilm.com'
role :db,  'db.checkafilm.com', :primary => true

set :user, 'www-data'
set :deploy_to, '/data/apps/checkafilm'

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after 'deploy:update_code', 'deploy:symlink_db'

namespace :deploy do
  desc 'Symlinks the database.yml'
  task :symlink_db, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
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