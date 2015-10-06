require "bundler/capistrano"
require "rvm/capistrano"

server "106.187.45.137", :web, :app, :db, primary: true

set :application, "lex"
set :user, "rails"
set :port, 22
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git@github.com:hxgdzyuyi/wordlist.git"
set :branch, "master"


default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases

namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      run "/etc/init.d/unicorn_#{application} #{command}"
    end
  end

  task :setup_config, roles: :app do
    sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
    run "mkdir -p #{shared_path}/config"
    run "mkdir -p #{shared_path}/public/uploads"
    run "mkdir -p #{shared_path}/node_modules"
    put File.read(".env"), "#{shared_path}/.env"
    puts "Now edit the config files in #{shared_path}."
  end
  after "deploy:setup", "deploy:setup_config"

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/public/uploads #{release_path}/public/uploads"
    run "ln -nfs #{shared_path}/node_modules #{release_path}/node_modules"
    run "ln -nfs #{shared_path}/.env #{release_path}/.env"
  end
  after "deploy:finalize_update", "deploy:symlink_config"

  desc "Install node modules non-globally"
  task :npm_install, roles: :app do
    run "cd #{release_path} && npm install"
  end
  after "deploy:update_code", "deploy:npm_install"

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"
end
