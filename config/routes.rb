InformedCinema::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  mount Resque::Server.new, :at => '/resque'

  devise_for :users
  resources :title, :controller => :movies, :only => [:index, :show], :as => :movie

  match 'search' => 'movies#search', :as => :search
  match 'search/:query' => 'movies#search'
  root :to => 'movies#home'
end
