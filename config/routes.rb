require 'resque/server'

Checkafilm::Application.routes.draw do

  match 'assets/tmdb/:size/:path' => 'assets#tmdb', :as => :tmdb_asset

  mount Resque::Server.new, :at => '/jobs'

  match '/title' => 'titles#index', :as => :titles
  match '/title/:id' => 'titles#show', :as => :title
  match '/find' => 'titles#search', :as => :search

  match '/tmdb/:id' => 'titles#tmdb', :as => :tmdb_redirect

  root :to => 'titles#index'
end
