class MoviesController < ApplicationController

  respond_to :html, :json

  def home
    @movies = Movie.order('updated_at DESC').limit(12).includes(:subtitles)
    respond_with @movies
  end

  def index
    redirect_to :root
  end

  def search
    @query = params[:query]
    @movies = Movie.search(@query)
    respond_with @movies
  end

  def show
    imdbid = params[:id]
    if imdbid == 'undefined' or !!!imdbid
      redirect_to :root
      return
    end
    @movie = Movie.find_or_create_by_imdbid(imdbid)
    @movie.async_load_all_information if @movie.added?
    respond_with @movie
  end

end
