$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
Require "rvm/capistrano"                  # Load RVM's capistrano plugin.
Set :rvm_ruby_string, 'ruby-1.9.2-p290@timit'      
Set :rvm_type, :user 
#set :default_environment, {
#  'PATH' => "/var/www/timit2/.rvm/gems/ruby-1.9.2-p290/bin:/var/www/timit2/.rvm/bin:/var/www/timit2/.rvm/rubies/ruby-1.9.2-p290/bin:$PATH",
#  'RUBY_VERSION' => 'ruby 1.9.2',
#  'GEM_HOME'     => '/var/www/timit2/.rvm/gems/ruby-1.9.2-p290@timit',
#  'GEM_PATH'     => '/var/www/timit2/.rvm/gems/ruby-1.9.2-p290@timit',
#  'BUNDLE_PATH'  => '/var/www/timit2/.rvm/gems/ruby-1.9.2-p290@timit'  # If you are using bundler.
#}

require "bundler/capistrano"
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'deploy')
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
