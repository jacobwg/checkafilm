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
    @movies = []
    unless @query.nil?
      begin
        uri = "http://api.themoviedb.org/2.1/Movie.search/en-US/json/#{Settings.tmdb_key}/#{CGI::escape(@query)}"
        result = Curl::Easy.perform(uri).body_str
        unless !!(result.match(/^<h1>Not Found/)) or !!(result.match(/^\["Nothing found/))
          @movies = JSON.parse(result)
          unless @movies.empty?
            @movies = @movies.map do |i|
              hash = {
                title: i['name'],
                slug: i['imdb_id'],
                mpaa_rating: i['certification']
              }
              hash[:poster_url] = i['posters'].first['image']['url'] if i['posters'].first
              hash[:year] = i['released'].split(/-/).first.to_i if i['released']
              Hashie::Mash.new(hash)
            end
          end
        end
      rescue nil
      end
    end
    respond_with @movies
  end

  def show
    imdbid = params[:id]
    if imdbid == 'undefined' or !!!imdbid
      redirect_to :root
      return
    end
    @movie = Movie.find_or_create_by_imdbid(imdbid)
    @movie.async_load_information #if @movie.added?

    respond_with @movie
  end

end
