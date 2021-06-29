# frozen_string_literal: true

$:.push File.expand_path('lib', __dir__)
require 'solidus_sale_prices/version'

Gem::Specification.new do |s|
  s.name = 'solidus_sale_prices'
  s.version = SolidusSalePrices::VERSION
  s.summary = 'Adds sale pricing functionality to Solidus.'
  s.description = 'Adds sale pricing functionality to Solidus. It enables timed sale planning for different currencies.'
  s.license  = 'BSD-3-Clause'

  s.author = 'Renuo GmbH, Jonathan Dean, Nebulab'
  s.email = 'info@nebulab.it'
  s.homepage = 'https://github.com/solidusio-contrib/solidus_sale_prices'

  if s.respond_to?(:metadata)
    s.metadata["homepage_uri"] = s.homepage if s.homepage
    s.metadata["source_code_uri"] = s.homepage if s.homepage
  end

  s.required_ruby_version = '~> 2.5'

  s.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  s.test_files = Dir['spec/**/*']
  s.bindir = "exe"
  s.executables = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  solidus_version = [">= 1.0", "< 3"]

  s.add_dependency 'deface', '~> 1.0'
  s.add_dependency 'discard'
  s.add_dependency 'solidus_api', solidus_version
  s.add_dependency 'solidus_backend', solidus_version
  s.add_dependency 'solidus_core', solidus_version
  s.add_dependency 'solidus_support', '~> 0.5'

  s.add_development_dependency 'timecop', '~> 0.9'
  s.add_development_dependency 'solidus_dev_support'
end
