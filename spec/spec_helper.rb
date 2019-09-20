require "simplecov"
SimpleCov.start "rails"

ENV["RAILS_ENV"] ||= "test"

require File.expand_path('dummy/config/environment.rb', __dir__)

require 'timecop'
require 'solidus_support/extension/feature_helper'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

# Requires factories defined in lib/spree_sale_prices/factories.rb
load "#{File.dirname(__FILE__)}/../lib/solidus_sale_prices/factories.rb"

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.raise_errors_for_deprecations!
end
