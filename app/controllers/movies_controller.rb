class MoviesController < ApplicationController

  respond_to :html, :json

  def index
    respond_with do |format|
      format.json { render_for_api :public, :json => @movies}
    end
  end

  def show
    imdbid = params[:id]
    if imdbid == 'undefined'
      redirect_to :root
      return
    end
    @movie = Movie.find_or_create_by_imdbid(imdbid)
    @movie.async_load_information if @movie.added?

    respond_with do |format|
      format.json { render_for_api :public, :json => @movie, :root => :movie }
    end
  end

end
