require 'sidekiq/web'

InformedCinema::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  mount Sidekiq::Web => '/sidekiq'

  devise_for :users
  resources :movies, :only => [:index, :show]
  root :to => 'movies#index'
end
