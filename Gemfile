source 'http://rubygems.org'

gem 'rails', '3.1.0'
gem 'rack', '1.3.3' # get rid of nasty messages

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'
gem 'pg'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
  gem "compass", "~>0.12.alpha.0"
end

gem 'jquery-rails'
gem 'therubyracer'

# Use haml instead of erb
gem 'haml'
gem 'haml-rails'
# nicer forms
gem 'formtastic'
gem 'schema_plus'

gem 'state_machine'
gem 'strip_attributes', '~>1.0'
gem 'will_paginate', '~>3.0'
### BUG: devise nicht vor strip_attributes laden
gem 'devise'
gem 'cancan'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :development, :test do
 gem 'rspec-rails'
 gem 'cucumber-rails'
 gem 'webrat'
 gem 'database_cleaner'
 gem 'factory_girl_rails', "~> 1.2.0"
 gem 'guard-rspec'
 # gem 'guard-livereload'
 # gem 'yajl-ruby'
 gem 'rb-inotify'
 gem 'libnotify'
 gem 'rails3-generators'
 gem 'accept_values_for'
 gem 'simplecov', :require => false
 gem 'spork', '> 0.9.0.rc'
 gem 'guard-spork'
end
group :test do
  # Pretty printed test output
  gem 'turn', :require => false
end
