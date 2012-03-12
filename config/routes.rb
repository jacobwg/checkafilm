require 'sidekiq/web'

InformedCinema::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  mount Sidekiq::Web => '/sidekiq'

  devise_for :users
  resources :title, :controller => :movies, :only => [:index, :show]

  match 'search' => 'movies#search', :as => :search
  match 'search/:query' => 'movies#search'
  root :to => 'movies#home'
end
