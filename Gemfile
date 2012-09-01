source 'https://rubygems.org'

# Rails
gem 'rails', '3.2.6'

# Database
gem 'mysql2'

# Asset processing
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.0.3'
  gem 'jquery-ui-rails'
end

# jQuery JavaScript framework
gem 'jquery-rails'

# Application setttings
gem 'settingslogic'

# IMDb API
gem 'imdb'

# HTML and XML parser
gem 'nokogiri'

# Native curl bindings - for downloading stuff
gem 'curb'

# Stuff being used for custom TMDb, RottenTomatoes, and YouTube API clients
gem 'deepopenstruct'
gem 'yajl-ruby', :require => 'yajl/json_gem'
gem 'addressable', :require => 'addressable/uri'

# File uploads (posters, backdrops, and trailer thumbnails)
gem 'carrierwave'
gem 'mini_magick'

# AWS integration for carrierwave
gem 'fog'

# Background job processing
gem 'resque'
gem 'resque-loner'
gem 'resque-pool'

# Title state machine
gem 'aasm'

# Memcached cache store
gem 'dalli'

# Deployment
group :development do
  gem 'mina'
end

# Profiling and dev server
group :development do
  gem 'ruby-prof'
  gem 'thin'
end

# Scheduler
gem 'whenever', :require => false

# New Relic
gem 'newrelic_rpm'

# HTTP Clients
gem 'rest-client', :require => 'rest_client'
gem 'faraday'
