require 'simplecov'
SimpleCov.start 'rails'
require 'rubygems'
require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require "rails/application"
  Spork.trap_method(Rails::Application::RoutesReloader, :reload!)
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'accept_values_for'
  
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
  
  RSpec.configure do |config|
    config.mock_with :rspec
    config.use_transactional_fixtures = true
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run :focus => true
    config.run_all_when_everything_filtered = true
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
end

Spork.each_run do
  FactoryGirl.reload
end



