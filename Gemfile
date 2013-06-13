source 'http://rubygems.org'

gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'pg'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.2.3"
  gem 'coffee-rails', "~> 3.2.1"
  gem 'uglifier', '>= 1.0.3'
  gem 'therubyracer', :platforms => :ruby
  gem "compass-rails"
end

gem 'jquery-rails'
gem 'therubyracer'

# Use haml instead of erb
gem 'haml'
gem 'haml-rails'
# nicer forms
gem 'formtastic'
gem 'nested_form', :git => 'git://github.com/ryanb/nested_form.git'
gem 'schema_plus'

gem 'state_machine'
gem 'strip_attributes'
gem 'will_paginate'
### BUG: devise nicht vor strip_attributes laden
gem 'devise'
gem 'cancan'
gem 'icalendar'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano'
gem 'exception_notification'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :development, :test do
  gem 'rails3-generators'
  gem 'accept_values_for'
  gem "pry-rails"
  gem "pry-doc"
  gem "better_errors"
  gem "binding_of_caller"
end

group :test do
  # Pretty printed test output
  gem 'rspec-rails'
  gem 'cucumber-rails', :require => false
  gem 'webrat'
  gem 'database_cleaner'
  gem 'factory_girl_rails', "~> 1.6.0"
  gem 'guard-rspec'
  gem 'guard-bundler'
  gem 'guard-zeus'
  # gem 'guard-livereload'
  # gem 'yajl-ruby'
  gem 'rb-inotify'
  gem 'libnotify'
  gem 'turn', :require => false
  gem 'simplecov', :require => false
  #gem 'spork', '> 0.9.0.rc'
  #gem 'guard-spork'
  gem 'shoulda-matchers'
  gem "rails3_pg_deferred_constraints"
end
