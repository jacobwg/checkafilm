class Title < ActiveRecord::Base

  # Include text helpers for pluralize
  include ActionView::Helpers::TextHelper

  # IDs
  attr_accessible :imdb_id, :tmdb_id

  # Basic Details
  attr_accessible :name, :plot_details, :plot_summary, :mpaa_rating, :release_date
  attr_accessible :release_date_dvd

  # Critic Ratings
  attr_accessible :rotten_tomatoes_critics_rating
  attr_accessible :rotten_tomatoes_critics_score
  attr_accessible :rotten_tomatoes_critics_consensus

  # User Ratings
  attr_accessible :imdb_rating, :imdb_votes
  attr_accessible :tmdb_rating, :tmdb_votes
  attr_accessible :rotten_tomatoes_audience_rating
  attr_accessible :rotten_tomatoes_audience_score

  # Media Details
  attr_accessible :runtime

  # Additional Multimedia
  attr_accessible :poster
  attr_accessible :backdrops, :backdrop_ids

  # Links
  attr_accessible :rotten_tomatoes_link
  attr_accessible :imdb_link
  attr_accessible :tmdb_link
  attr_accessible :plugged_in_link
  attr_accessible :kids_in_mind_link
  attr_accessible :homepage

  # Content
  attr_accessible :kids_in_mind_sex_number
  attr_accessible :kids_in_mind_language_number
  attr_accessible :kids_in_mind_violence_number
  attr_accessible :plugged_in_review

  # Relations
  has_many :backdrops, dependent: :destroy
  has_many :trailers, dependent: :destroy

  # Serialized fields
  serialize :plugged_in_review, Hash

  # Uploaders
  mount_uploader :poster, PosterUploader

  # Scopes
  scope :new_releases, where(:status_state => 'loaded').where('release_date <= :current_date', current_date: Date.today).order('release_date DESC').limit(16)
  scope :new_on_dvd, where(:status_state => 'loaded').where('release_date_dvd <= :current_date', current_date: Date.today).order('release_date_dvd DESC').limit(16)
  scope :recently_added, where(:status_state => 'loaded').order('created_at DESC').limit(16)
  scope :recently_updated, where(:status_state => 'loaded').order('updated_at DESC').limit(16)

  # Status state
  include AASM
  aasm :column => :status_state do
    # Default state for newly added titles
    state :fresh, :initial => true

    # State for movies that have been info-loaded at least once
    state :loaded

    # State for movies that are blocked from display (like adult movies)
    state :blocked

    # State for movies that cannot be found
    state :missing

    event :make_fresh do
      transitions :to => :fresh, :from => [:missing, :blocked]
    end

    event :make_loaded do
      transitions :to => :loaded, :from => [:fresh, :missing]
    end

    event :make_blocked do
      transitions :to => :blocked, :from => [:fresh, :loaded, :missing]
    end

    event :make_missing do
      transitions :to => :missing, :from => [:fresh]
    end
  end

  # API
  acts_as_api

  api_accessible :public do |template|
    template.add :id
    template.add :imdb_id
    template.add :status_state
    template.add :jobs
  end

  # Permalinks
  def to_param
    imdb_id
  end

  # Fetch and save basic information from IMDb, TMDb, and Rotten Tomatoes
  def fetch_basic_data!
    return if blocked? or not imdb_id?
    Rails.logger.info('Loading data...')
    begin
      tmdb_data = Tmdb.api_call 'movie', :id => imdb_id, language: 'en'
    rescue RuntimeError
      Rails.logger.warn('Movie not found - exiting...')
      make_missing!
      return
    rescue Exception
      return
    end

    if tmdb_data['adult'] == true
      Rails.logger.warn('Adult movie - exiting...')
      make_blocked!
      return
    end

    make_fresh if missing?

    releases = Tmdb.api_call 'movie/releases', id: tmdb_data['id'], language: 'en'
    if releases['countries'] and releases['countries'].size > 0
      release = releases['countries'].delete_if { |r| r['iso_3166_1'] != 'US' }
      release = release.first
      tmdb_data['release'] = release
    end

    tmdb_data = Tmdb.data_to_object(tmdb_data)
    imdb_data = Imdb::Movie.new(self.imdb_id.gsub(/tt/, ''))
    rotten_tomatoes_data = RottenTomatoes.lookup(self.imdb_id)

    # IDs
    self.tmdb_id = tmdb_data.id

    # Basic Details
    self.name = tmdb_data.title
    self.plot_summary = imdb_data.plot
    self.plot_details = tmdb_data.overview
    self.mpaa_rating = tmdb_data.release.certification
    self.release_date = Date.parse(tmdb_data.release.release_date)
    self.release_date_dvd = Date.parse(rotten_tomatoes_data.release_dates.dvd) unless rotten_tomatoes_data.release_dates.dvd.nil?

    # Critic Ratings
    self.rotten_tomatoes_critics_rating = rotten_tomatoes_data.ratings.critics_rating
    self.rotten_tomatoes_critics_score = rotten_tomatoes_data.ratings.critics_score
    self.rotten_tomatoes_critics_consensus = rotten_tomatoes_data.critics_consensus

    # User Ratings
    self.tmdb_rating = tmdb_data.vote_average
    self.tmdb_votes = tmdb_data.vote_count
    self.imdb_rating = imdb_data.rating
    self.imdb_votes = imdb_data.votes
    self.rotten_tomatoes_audience_rating = rotten_tomatoes_data.ratings.audience_rating
    self.rotten_tomatoes_audience_score = rotten_tomatoes_data.ratings.audience_score

    # Media Details
    self.runtime = tmdb_data.runtime

    # Links
    self.rotten_tomatoes_link = rotten_tomatoes_data.links.alternate
    self.imdb_link = "http://www.imdb.com/title/#{self.imdb_id}/"
    self.tmdb_link = "http://www.themoviedb.org/movie/#{self.tmdb_id}"
    self.homepage = tmdb_data.homepage

    save

    Rails.logger.info('Basic data loaded...')

  end

  # Download and save poster and backdrops from TMDb
  def fetch_images!
    return if blocked? or missing?

    images = Tmdb.api_call 'movie/images', id: self.tmdb_id
    images = Tmdb.data_to_object(images)

    Rails.logger.info('Saving poster...')

    posters = images.posters.keep_if { |p| p.iso_639_1.nil? or p.iso_639_1 == 'en' }
    poster = posters.first

    if poster.file_path
      poster_url = poster.sizes.original.url
    else
      imdb_data = Imdb::Movie.new(self.imdb_id.gsub(/tt/, ''))
      poster_url = imdb_data.poster
    end

    unless self.original_poster_url == poster_url
      self.original_poster_url = poster_url
      self.remote_poster_url = poster_url
    end

    save

    Rails.logger.info('Posters saved...')

    Rails.logger.info('Saving backdrops...')

    backdrop_urls = []
    images.backdrops.each do |backdrop|
      backdrop_urls << backdrop.sizes.original.url if backdrop.file_path
    end

    backdrops_to_delete = {}
    self.backdrops.each {|b| backdrops_to_delete[b.original_url] = {delete: true, obj: b} }

    backdrop_urls.each do |url|
      backdrops_to_delete[url][:delete] = false if backdrops_to_delete[url]
      backdrop = Backdrop.find_by_original_url(url)
      unless backdrop
        backdrop = Backdrop.new(title_id: self.id, original_url: url, remote_image_url: url)
        backdrop.save
      end
    end

    backdrops_to_delete.each do |url, b|
      b[:obj].destroy if b[:delete]
    end

    Rails.logger.info('Backdrops saved...')

  end

  # Fetch and save trailers from TMDb and YouTube
  def fetch_trailers!
    return if blocked? or missing?

    Rails.logger.info('Fetching trailers...')

    trailers = Tmdb.api_call 'movie/trailers', id: self.tmdb_id, language: 'en'
    trailers = Tmdb.data_to_object(trailers)

    if trailers.youtube.size > 0
      trailers.youtube.each do |t|
        puts t.source
        t.source.gsub!(/http:\/\/.*youtube.com\/watch\?v=/, '') unless t.source.nil?
        t.source.gsub!(/&.*$/, '') unless t.source.nil?
        trailer = Trailer.find_by_url(t.source)
        unless trailer
          trailer = Trailer.new(url: t.source, name: t.name, title_id: self.id)
          trailer.save
          trailer.fetch_thumbnail!
        end
      end
    else
      trailers = Youtube.search("#{self.name} (#{self.release_date.year}) trailer")
      unless trailers.empty?
        t = trailers.first
        trailer = Trailer.find_by_url(t[:id])
        unless trailer
          trailer = Trailer.new(url: t[:id], name: t[:name], title_id: self.id)
          trailer.save!
          trailer.fetch_thumbnail!
        end
      end
    end

    Rails.logger.info('Trailers fetched...')
  end

  # Fetch and save review information from Plugged In and Kids in Mind
  def fetch_review_information!
    return if blocked? or missing?

    Rails.logger.info('Fetching review information')

    search_title = "#{self.name}"
    search_title = "#{search_title} (#{self.release_date.year})" if self.release_date?

    if (pi_movie = PluggedIn.search(search_title))
      match = pi_movie.match(name, release_date.try(:year))
      self.plugged_in_link = pi_movie.url if (match[:year] == 0 and match[:title] < 5)
    end

    if (kim_movie = KidsInMind.search(search_title))
      match = kim_movie.match(name, release_date.try(:year))
      if (match[:year] == 0 and match[:title] < 5)
        self.kids_in_mind_link = kim_movie.url
        self.kids_in_mind_sex_number = kim_movie.sex
        self.kids_in_mind_violence_number = kim_movie.violence
        self.kids_in_mind_language_number = kim_movie.language
      end
    end

    save

    Rails.logger.info('Review information fetched')
  end

  # Fetch the Plugged In review paragraphs (currently using the conclusion)
  def fetch_plugged_in_review!
    return unless plugged_in_link?
    m = PluggedIn::Movie.new(plugged_in_link)
    self.plugged_in_review = m.review_data
    save
  end

  # Completely load a title
  def load!
    fetch_basic_data!
    fetch_images!
    fetch_trailers!
    fetch_review_information!
    fetch_plugged_in_review!
    make_loaded! if fresh?
  end

  # Async load a title
  def async_load!
    Job.enqueue(LoadJob, jobs_set, id: self.id)
  end

  def jobs_set
    "title:#{self.id}"
  end

  def jobs
    jobs = Job.jobs(jobs_set)
    jobs.map { |j| Job.get(j) }
  end

  def jobs_clear
    Job.clear(jobs_set)
  end

  def active_job?(type)
    active = false
    jobs.each do |job|
      active = true if job.status != 'completed' and job.name.match(type)
    end
    active
  end

  # Return page title
  def page_title
    if fresh?
      'Loading...'
    elsif blocked?
      'Blocked'
    elsif missing?
      'Not Found'
    elsif release_date?
      "#{name} (#{release_date.year})"
    else
      name
    end
  end

  # Helper to refresh all titles
  def self.refresh_all
    Title.find_each do |t|
      t.async_fetch_information!
    end
  end

  # Build montage image for homepage
  def self.build_montage
    titles = self.new_releases
    images = titles.map { |t| t.poster_url(:thumb) }
    images.map! { |i| MiniMagick::Image.open(i) }
    paths = images.map { |i| i.path }

    output = Rails.root.join('public', 'montage.jpg')

    command = "montage -tile x2 -geometry 200x300 -background black #{paths.join ' '} #{output}"
    system(command)
    command = "convert #{output} -fill black -colorize 75% #{output}"
    system(command)
  end

  # Schedule building of montage
  def self.async_build_montage
    TitleMontageJob.create
  end

end
