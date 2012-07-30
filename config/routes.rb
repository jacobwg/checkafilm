require 'resque/server'

Checkafilm::Application.routes.draw do


  # Resque web monitor interface
  mount Resque::Server.new, :at => '/jobs'

  # Title index and show
  match 'title' => 'titles#index', :as => :titles
  match 'title/:id' => 'titles#show', :as => :title

  # Search
  match 'find' => 'titles#search', :as => :search

  # TMDb ID redirect
  match 'tmdb/:id' => 'titles#tmdb', :as => :tmdb_redirect

  # Proxy for TMDb posters
  match 'assets/tmdb/:size/:path' => 'assets#tmdb', :as => :tmdb_asset

  # About page
  get 'about' => 'pages#about', :as => :about

  # Root page
  root :to => 'titles#index'
end
