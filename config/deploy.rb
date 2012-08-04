require 'mina/bundler'
require 'mina/rails'
require 'mina/git'

# Basic settings:
# domain     - The hostname to SSH to
# deploy_to  - Path to deploy into
# repository - Git repo to clone from (needed by mina/git)
# user       - Username in the  server to SSH to (optional)

set :domain, 'app.checkafilm.com'
set :deploy_to, '/data/apps/checkafilm'
set :repository, 'https://github.com/jacobwg/checkafilm.git'
set :user, 'web'
# set :port, '30000'

set :shared_paths, ['config/database.yml', 'config/application.yml', 'log']

desc "Deploys the current version to the server."
task :deploy do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'

    to :launch do
      queue 'touch tmp/restart.txt'
    end
  end
end
