require 'sidekiq/web'

InformedCinema::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  mount Sidekiq::Web => '/sidekiq'

  devise_for :users
  resources :title, :controller => :movies, :only => [:index, :show]
  root :to => 'movies#home'
end
