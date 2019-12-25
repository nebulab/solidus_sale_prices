source 'http://rubygems.org'

branch = ENV.fetch('SOLIDUS_BRANCH', 'master')
gem "solidus", github: "solidusio/solidus", branch: branch

gem 'pg', '~> 1.2'
gem 'mysql2'

# In order to allow testing on older version of Solidus that still
# use the gem factory_girl we need to bundle an older version of
# factory_bot:
gem 'factory_bot', github: 'thoughtbot/factory_bot', ref: 'f1f77'

gemspec
