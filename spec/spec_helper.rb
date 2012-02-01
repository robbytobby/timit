require 'rubygems'
require 'spork'

Spork.prefork do
  require 'simplecov'
  SimpleCov.start 'rails'

  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'accept_values_for'
  Spork.trap_method(Rails::Application::RoutesReloader, :reload!)
  
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
  
  RSpec.configure do |config|
    config.mock_with :rspec
    config.use_transactional_fixtures = true
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



