source 'https://rubygems.org'

# ruby '2.6.6'
ruby '2.6.8'
gem 'rails', '4.2.11'
gem 'ffi', '~> 1.15.0'
gem 'sass-rails', '~> 5.0.3'
gem 'uglifier', '>= 2.7.1'

gem 'jquery-rails'

# gem "webmock", '2.3.2'

# gem "webmock", '2.8.0'

gem 'faraday', '1.8.0'  # in main group; simplifies calling TMDb
group :test do
  gem 'rails-controller-testing'
  gem 'guard-rspec'                 # automates re-running tests
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end

# for Heroku deployment - as described in Ap. A of ELLS book
group :development, :test do
  gem 'byebug'
  gem 'database_cleaner'
  gem 'cucumber-rails', require: false
  gem 'rspec-rails'

  gem 'pry'
  gem 'pry-byebug', '~> 3.9.0'

  # Use sqlite3 as the database for Active Record
  gem 'sqlite3', '~> 1.3.6'
end

group :production do
  gem 'pg', '~> 0.2'
  gem 'rails_12factor'
end
