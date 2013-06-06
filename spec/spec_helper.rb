require 'simplecov'
SimpleCov.start 'rails'
require 'rubygems'
#require 'spork'

  ENV["RAILS_ENV"] ||= 'test'
  #require "rails/application"
  #Spork.trap_method(Rails::Application::RoutesReloader, :reload!)
  #Spork.trap_method(Rails::Application, :reload_routes!)
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  #require 'rspec/autorun'
  require 'accept_values_for'
  require 'discover'
  require 'database_cleaner'
  
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
  
  RSpec.configure do |config|
    #config.include Devise::TestHelpers, :type => :controller
    #config.include Devise::TestHelpers, :type => :helper
    config.mock_with :rspec
    config.use_transactional_fixtures = false
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run :focus => true
    config.run_all_when_everything_filtered = true
    config.infer_base_class_for_anonymous_controllers = false


    config.before(:suite) do
      DatabaseCleaner.clean_with(:truncation)
    end
  
    config.before(:each) do
      DatabaseCleaner.strategy = :transaction
    end
  
    config.before(:each, :js => true) do
      DatabaseCleaner.strategy = :truncation
    end
  
    config.before(:each) do
      DatabaseCleaner.start
    end
  
    config.after(:each) do
      DatabaseCleaner.clean
    end
  end

  class ActionView::TestCase::TestController
    def default_url_options(options={})
      { :locale => I18n.default_locale }
    end
  end

  class ActionDispatch::Routing::RouteSet
    def default_url_options(options={})
      { :locale => I18n.default_locale }
    end
  end



