require 'bundler/capistrano'

set :application, 'set your application name here'

set :scm, :git
set :repository,  'set your repository location here'
set :deploy_via, :remote_cache
set :branch, 'master'

role :web, 'web.checkafilm.com'
role :app, 'app.checkafilm.com'
role :db,  'db.checkafilm.com', :primary => true

set :user, 'www-data'

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

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