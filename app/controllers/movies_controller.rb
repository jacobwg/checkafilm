class MoviesController < ApplicationController
  # GET /movies
  # GET /movies.json
  def index
    @movies = Movie.order('updated_at DESC').all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render_for_api :public, :json => @movies}
    end
  end

  def search
    query = params[:query]
    @search = Movie.search(query)
    if @search.empty?
      @json = {
        query: query,
        suggestions: [],
        data: []
      }
    else
      @json = {
        query: query,
        suggestions: @search.map { |i| i['name'] },
        data: @search.map { |i| i['imdb_id'] }
      }
    end

    render json: @json
  end

  # GET /movies/1
  # GET /movies/1.json
  def show
    imdbid = params[:id]
    if imdbid == 'undefined'
      redirect_to :root
      return
    end
    @movie = Movie.find_or_create_by_imdbid(imdbid)
    @movie.async_load_information if @movie.added?

    respond_to do |format|
      format.html # show.html.erb
      format.json { render_for_api :public, :json => @movie, :root => :movie }
    end
  end

  # GET /movies/new
  # GET /movies/new.json
  def new
    @movie = Movie.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @movie }
    end
  end

  # GET /movies/1/edit
  def edit
    @movie = Movie.find(params[:id])
  end

  # POST /movies
  # POST /movies.json
  def create
    @movie = Movie.new(params[:movie])

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: 'Movie was successfully created.' }
        format.json { render json: @movie, status: :created, location: @movie }
      else
        format.html { render action: "new" }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /movies/1
  # PUT /movies/1.json
  def update
    @movie = Movie.find(params[:id])

    respond_to do |format|
      if @movie.update_attributes(params[:movie])
        format.html { redirect_to @movie, notice: 'Movie was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1
  # DELETE /movies/1.json
  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy

    respond_to do |format|
      format.html { redirect_to movies_url }
      format.json { head :no_content }
    end
  end
end
