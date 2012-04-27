class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :remove_heroku

  def remove_heroku
    redirect_to(request.protocol + 'checkafilm.com' + request.fullpath) if /herokuapp/.match(request.host)
  end

end
