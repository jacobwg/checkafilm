class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :load_movies
  def load_movies
    @movies = Movie.order('updated_at DESC').all
  end
end
