source 'https://rubygems.org'

gem 'rails', '3.2.11'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'omniauth-google-oauth2'

group :production do
  gem 'pg'
end
group :development do
  gem 'sqlite3'
end

gem 'simple_form'
gem 'pivotal-tracker', :git => 'git://github.com/donihanafi/pivotal-tracker.git'
gem 'harvested', :git => 'git://github.com/fajarmf/harvested.git'
gem 'hiro',path:'../hiro'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem "compass-rails"

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
	gem 'rspec-rails'
	gem 'shoulda-matchers'
end

gem "jquery-rails", "~> 2.2.1"
gem "bootstrap-sass", "~> 2.2.2.0"

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

# Background job
gem 'resque', :require => 'resque/server'
gem 'resque-pool'
gem 'resque_mailer'
