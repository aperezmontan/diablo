# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/app/controllers/users/' # Devise generated controllers
end
# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  Shoulda::Matchers.configure do |shoulda_matcher_config|
    shoulda_matcher_config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end
end
