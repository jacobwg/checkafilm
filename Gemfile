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
end

# jQuery JavaScript framework
gem 'jquery-rails'

# HAML markup language
gem 'haml'
gem 'haml-rails'

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

# Permalinks (TODO: look into to_param)
gem 'friendly_id'

# Application server
gem 'unicorn'

# Background job processing
gem 'resque'
gem 'resque-lock-timeout'
gem 'resque-pool'

# Title state machine
gem 'aasm'

# Memcached cache store
gem 'dalli'

# Deployment
group :development do
  gem 'capistrano'
end
