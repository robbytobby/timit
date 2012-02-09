$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, 'ruby-1.9.2-p290@timit'      
set :rvm_type, :user 

require "bundler/capistrano"
require "cap_db_config"
require "cap_passenger"

set :application, "timit2"

set :repository,  "git@github.com:robbytobby/timit.git"
set :scm, :git
set :branch, "master"
set :deploy_via, :remote_cache

set :user, "timit2"
set :use_sudo, false
set :deploy_to, "/var/www/#{application}"

role :web, "sw2.chemie.uni-freiburg.de"                          # Your HTTP server, Apache/etc
role :app, "sw2.chemie.uni-freiburg.de"                          # This may be the same as your `Web` server
role :db,  "sw2.chemie.uni-freiburg.de", :primary => true # This is where Rails migrations will run

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
#namespace :deploy do
#  task :start do ; end
#  task :stop do ; end
#  task :restart, :roles => :app, :except => { :no_release => true } do
#    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#  end
#end
