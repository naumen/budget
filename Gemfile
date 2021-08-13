source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


gem 'rails', '~> 5.1.4'
gem 'mysql2', '>= 0.3.18', '< 0.5'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'haml', '~>  5.0.3'
gem 'haml-rails', '~> 1.0'
gem 'bootstrap', '~> 4.0.0.beta2.1'
gem 'jquery-rails'
gem 'acts_as_tree'
gem 'awesome_nested_set'
gem 'will_paginate', '~> 3.1.0'
gem 'select2-rails'
gem 'unicorn'
gem 'rails_db_dump'
gem 'delayed_job_active_record'
gem 'pry'
gem 'pi_charts'
gem 'mina'
gem 'net-ldap'
gem 'open-iconic-rails'
gem 'rest-client'
gem 'kramdown'
gem 'whenever', :require => false
 
group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
  gem 'sqlite3'
  gem 'minitest-reporters'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem "seedbank"
  gem 'active_record_query_trace'
  gem 'thin'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
