require 'resque/server'

InformedCinema::Application.routes.draw do
  mount Resque::Server.new, :at => "/resque"
  resources :movies, :only => [:index, :show]
  root :to => 'movies#index'
end
