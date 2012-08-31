Tmdb.api_key = Settings.tmdb_key

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

    begin

      uri = "http://www.google.com/search?ie=UTF-8&q=site%3Awww.kids-in-mind.com+#{CGI::escape(search_title)}"
      result = Curl::Easy.perform(uri).body_str
      doc = Nokogiri::HTML(result)
      results = doc.css('h3.r a')
      filtered_results = results.to_a.reject { |i| not i.text.match(/[\[]/) }
      kim_uri = filtered_results.first

      if kim_uri.nil?
        kim_uri = results.first
      end

      unless kim_uri.nil?
        kim_uri = kim_uri['href']
        kim_uri = CGI.parse(URI.parse(kim_uri).query)['q'].first
        self.kids_in_mind_link = kim_uri
      end

      unless kim_uri.nil?
        begin
          result = Curl::Easy.perform(kim_uri).body_str
          doc = Nokogiri::HTML(result)
          sex = doc.css('img').reject { |i| i['src'].match(/ratings\/s&n/).nil? }
          violence = doc.css('img').reject { |i| i['src'].match(/ratings\/v&g/).nil? }
          profanity = doc.css('img').reject { |i| i['src'].match(/ratings\/prof/).nil? }

          sex = sex.first['src'].match(/images\/ratings\/s&n(\d+).jpg$/)[1] if sex.first
          violence = violence.first['src'].match(/images\/ratings\/v&g(\d+).jpg$/)[1] if violence.first
          profanity = profanity.first['src'].match(/images\/ratings\/prof(\d+).jpg$/)[1] if profanity.first

          self.kids_in_mind_sex_number = sex || nil
          self.kids_in_mind_violence_number = violence || nil
          self.kids_in_mind_language_number = profanity || nil
        rescue nil
        end
      end

      uri = "http://search.pluggedin.com/search?q=#{CGI::escape(search_title)}&btnG=Search&filter=&ntqr=0&output=xml_no_dtd&sort=date%3AD%3AL%3Ad1&client=pluggedin_com&filter=&ud=1&oe=UTF-8&ie=UTF-8&site=pluggedin_com&getfields=*"
      result = Curl::Easy.perform(uri).body_str
      doc = Nokogiri::XML(result)
      pi_uri = doc.css('U').first

      unless pi_uri.nil?
        pi_uri = pi_uri.content
        pi_uri = nil unless pi_uri.nil? or !!(pi_uri.match(/https?:\/\/(www.)?pluggedin.com\/(videos|movies)/))
      end

      if pi_uri.nil?
        search_title = self.name
        uri = "http://search.pluggedin.com/search?q=#{CGI::escape(search_title)}&btnG=Search&filter=&ntqr=0&output=xml_no_dtd&sort=date%3AD%3AL%3Ad1&client=pluggedin_com&filter=&ud=1&oe=UTF-8&ie=UTF-8&site=pluggedin_com&getfields=*"
        result = Curl::Easy.perform(uri).body_str
        doc = Nokogiri::XML(result)
        pi_uri = doc.css('U').first
        unless pi_uri.nil?
          pi_uri = pi_uri.content unless pi_uri.nil?
          pi_uri = nil unless !!(pi_uri.match(/https?:\/\/(www.)?pluggedin.com\/(videos|movies)/))
        end
      end

      self.plugged_in_link = pi_uri

    rescue Exception
    end
    save

    Rails.logger.info('Review information fetched')
  end

  # Fetch the Plugged In review paragraphs (currently using the conclusion)
  def fetch_plugged_in_review!
    return unless plugged_in_link?
    review = {}

    begin

      text = open(plugged_in_link).read
      doc = Nokogiri::HTML(text)

      if text.match /<p><p>/i
        # Old-style review
        puts "Old-style"
        doc.css('#article p').each do |p|
          section = p.css('b').text
          p.search('.//b').remove
          html = p.to_html
          if section.match /positive/i
            review[:positive_elements] = html
          elsif section.match /spiritual/i
            review[:spiritual_content] = html
          elsif section.match /sexual/i
            review[:sexual_content] = html
          elsif section.match /sexual/i
            review[:sexual_content] = html
          elsif section.match /conduct/i
            review[:violent_content] = html
          elsif section.match /violence/i
            review[:violent_content] = html
          elsif section.match /crude/i
            review[:crude_language] = html
          elsif section.match /drug/i
            review[:drug_content] = html
          elsif section.match /negative/i
            review[:negative_elements] = html
          elsif section.match /conclusion/i
            review[:conclusion] = html
          elsif section.match /summary/i
            review[:conclusion] = html
          else
            review[:introduction] = html
          end
        end
      else
        puts "New-style"
        # Newer review
        review[:introduction] = doc.css('#article p').first.to_html
        review[:positive_elements] = doc.css('h3.positiveElements + p').to_html
        review[:spiritual_content] = doc.css('h3.spiritualContent + p').to_html
        review[:sexual_content] = doc.css('h3.sexualContent + p').to_html
        review[:violent_content] = doc.css('h3.violentContent + p').to_html
        review[:crude_language] = doc.css('h3.crudeLanguage + p').to_html
        review[:drug_content] = doc.css('h3.drugContent + p').to_html
        review[:negative_elements] = doc.css('h3.negativeElements + p').to_html
        review[:conclusion] = doc.css('h3.conclusion + p').to_html
      end

      review.each do |key, value|
        review[key] = value.gsub(/<i>/, '<em>').gsub(/<\/i>/, '</em>')
        review[key] = value.gsub(/<a href="~/, '<a target="_blank" href="http://www.pluggedin.com/videos/2012/q1/~')
      end

      self.plugged_in_review = review

      save

    rescue Exception
    end
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
    Resque.enqueue(LoadJob, self.id)
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


end
