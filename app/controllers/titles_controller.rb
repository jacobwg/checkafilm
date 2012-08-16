class TitlesController < ApplicationController

  respond_to :html, :json

  caches_action :search, :expires_in => 1.hour, :cache_path => proc { |c| {:query => c.params[:q]} }

  def index
    @titles = Title.homepage
    respond_with @titles
  end

  def search
    if params[:q]
      @query = params[:q]
      @results = Tmdb.api_call 'search/movie', query: @query, language: 'en'
      if @results.nil?
        @results = []
      else
        @results = Tmdb.data_to_object(@results).results
      end
      respond_to do |format|
        format.html
      end
    else
      redirect_to :root
    end
  end

  def tmdb
    begin
      movie = Tmdb.api_call 'movie', id: params[:id]
      if movie['imdb_id']
        redirect_to title_path(movie['imdb_id'])
      else
        redirect_to :root
      end
    rescue Exception
      redirect_to :root
    end
  end

  def show
    @title = Title.find_by_imdb_id(params[:id])
    @title = Title.create!(imdb_id: params[:id]) unless @title
    @title.async_load! unless @title.blocked?
    respond_with @title
  end

end
