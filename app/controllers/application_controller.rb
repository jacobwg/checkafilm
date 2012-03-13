class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :load_movies
  def load_movies
    @movies = Movie.order('updated_at DESC').all
  end

  before_filter :remove_heroku

  def remove_heroku
    Rails.logger.info request.methods
    redirect_to(request.protocol + 'checkafilm.com' + request.fullpath) if /herokuapp/.match(request.host)
  end

end
