# encoding: UTF-8

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus_sale_prices'
  s.version     = '1.4.0'
  s.summary     = 'Adds sale pricing functionality to Solidus'
  s.description = 'Adds sale pricing functionality to Solidus. It enables timed sale planning for different currencies.'
  s.required_ruby_version = '>= 1.9.3'

  s.author   = 'Renuo GmbH, Jonathan Dean, Nebulab'
  s.email    = 'info@nebulab.it'
  s.homepage = 'https://github.com/nebulab/spree_sale_prices'
  s.license  = 'BSD-3'

  # s.files       = `git ls-files`.split("\n")
  # s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  solidus_version = [">= 1.0", "< 3"]

  s.add_runtime_dependency 'deface', '~> 1.0'

  s.add_dependency "solidus_api", solidus_version
  s.add_dependency "solidus_backend", solidus_version
  s.add_dependency "solidus_core", solidus_version
  s.add_dependency 'solidus_support', '~> 0.2'

  s.add_development_dependency 'rspec-rails', '~> 3.1'
  s.add_development_dependency 'capybara', '~> 2.4'
  s.add_development_dependency 'database_cleaner', '~> 1.4'
  s.add_development_dependency 'factory_bot', '~> 4.5'
  s.add_development_dependency 'simplecov', '~> 0.9'
  s.add_development_dependency 'sqlite3', '~> 1.3'
  s.add_development_dependency 'timecop', '~> 0.9'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'pry'
end
