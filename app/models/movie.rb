class Movie < ActiveRecord::Base

  require 'net/http'
  require 'open-uri'
  require 'iconv'

  validates :imdbid, :presence => true
  validates :imdbid, :uniqueness => true
  #validates :kim_sex, :kim_violence, :kim_language, :inclusion => { :in => 0..10 }

  has_many :subtitles

  mount_uploader :poster, PhotoAssetUploader
  mount_uploader :backdrop, PhotoAssetUploader

  ## API Control ##

  acts_as_api

  api_accessible :public do |template|
    template.add :id
    template.add :imdbid
    template.add :title
    template.add :year
    template.add :mpaa_rating
    template.add :plot_summary
    template.add :plot_details
    template.add :poster_url
    template.add :backdrop_url
    template.add :runtime
    template.add :rating
    template.add :votes
    template.add :tmdbid
    template.add :imdb_url
    template.add :tmdb_url
    template.add :amazon_url
    template.add :pluggedin_url
    template.add :kidsinmind_url
    template.add :kim_sex
    template.add :kim_violence
    template.add :kim_language
    template.add :created_at
    template.add :updated_at
    template.add :status
    template.add :slug
    template.add :subtitles
    template.add :added
  end

  def added
    added?
  end

  def is_server_response
    true
  end

  def title_with_year
    "#{self.title} (#{self.year})"
  end

  extend FriendlyId
  friendly_id :imdbid, use: :slugged

  include AASM
  aasm :column => :status do
    state :added, :initial => true
    state :has_information
    state :has_subtitles
    state :auto_reviewed
    state :reviewed
    state :has_no_subtitles
    state :invalid

    event :make_it_have_information do
      transitions :to => :has_information, :from => [:added]
    end
    event :make_it_have_subtitles do
      transitions :to => :has_subtitles, :from => [:has_information]
    end
    event :make_it_auto_reviewed do
      transitions :to => :aoth_reviewed, :from => [:has_subtitles]
    end
    event :make_it_reviewed do
      transitions :to => :reviewed, :from => [:auto_reviewed, :has_no_subtitles]
    end
    event :make_it_have_no_subtitles do
      transitions :to => :has_no_subtitles, :from => [:has_information]
    end
    event :make_it_invalid do
      transitions :to => :invalid, :from => [:added]
    end
  end

  def status_enum
    %w(added has_information has_subtitles auto_reviewed reviewed has_no_subtitles invalid)
  end


  def load_release_information!
    load_release_information
    self.save
  end

  def load_release_information
    imdb = Imdb::Movie.new(imdbid.gsub(/tt/, ''))
    if imdb.title.nil?
      self.make_it_invalid
      return
    end
    self.title = imdb.title
    self.year = imdb.year
    self.plot_summary = imdb.plot
    if imdb.length and imdb.length.to_i > 0
      self.runtime = ""
      self.runtime = "#{imdb.length.to_i / 60}hrs" if imdb.length.to_i / 60 > 0
      self.runtime = "#{self.runtime} #{imdb.length.to_i % 60}min" if imdb.length.to_i % 60 > 0
      self.runtime.strip!
    end
    self.rating = imdb.rating
    self.votes = imdb.votes
    self.imdb_url = "http://www.imdb.com/title/#{imdbid}/"

    uri = "http://api.themoviedb.org/2.1/Movie.imdbLookup/en-US/json/#{Settings.tmdb_key}/#{imdbid}"
    result = JSON.parse(Curl::Easy.perform(uri).body_str).first
    if result.include? "Nothing found"
      self.make_it_invalid
      return
    end

    self.plot_details = result['overview']
    self.tmdb_url = result['url']
    if imdb.mpaa_rating
      if imdb.mpaa_rating.index /\bNC-17\b/
        self.mpaa_rating = 'NC-17'
      elsif imdb.mpaa_rating.index /\bPG-13\b/
        self.mpaa_rating = 'PG-13'
      elsif imdb.mpaa_rating.index /\bPG\b/
        self.mpaa_rating = 'PG'
      elsif imdb.mpaa_rating.index /\bR\b/
        self.mpaa_rating = 'R'
      elsif imdb.mpaa_rating.index /\bG\b/
        self.mpaa_rating = 'G'
      else
        self.mpaa_rating = 'N/A'
      end
    elsif !result['certification'].nil? and result['certification'] != ''
      self.mpaa_rating = result['certification']
    else
      self.mpaa_rating = 'N/A'
    end
  end

  def load_posters!
    load_posters
    self.save
  end

  def load_posters
    imdb = Imdb::Movie.new(imdbid.gsub(/tt/, ''))
    self.remote_poster_url = imdb.poster
    uri = "http://api.themoviedb.org/2.1/Movie.imdbLookup/en-US/json/#{Settings.tmdb_key}/#{imdbid}"
    result = JSON.parse(Curl::Easy.perform(uri).body_str).first
    unless result.include? "Nothing found"
      tmdb_backdrop = {'image' => {'width' => 0, 'url' => ''}}
      result['backdrops'].each do |i|
        tmdb_backdrop = i if i['image']['width'] > tmdb_backdrop['image']['width']
      end
      self.remote_backdrop_url = tmdb_backdrop['image']['url']

      if self.remote_poster_url.nil?
        posters = result['posters']
        posters.keep_if { |i| i['image']['size'] == 'mid' }
        self.remote_poster_url = posters.first['image']['url'] unless posters.empty?
      end
    end
  end

  def load_reviews!
    load_reviews
    self.save
  end

  def load_reviews
    search_title = "#{title} [#{year}}"

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
        search_title = self.title
        uri = "http://search.pluggedin.com/search?q=#{CGI::escape(search_title)}&btnG=Search&filter=&ntqr=0&output=xml_no_dtd&sort=date%3AD%3AL%3Ad1&client=pluggedin_com&filter=&ud=1&oe=UTF-8&ie=UTF-8&site=pluggedin_com&getfields=*"
        result = Curl::Easy.perform(uri).body_str
        doc = Nokogiri::XML(result)
        pi_uri = doc.css('U').first
        unless pi_uri.nil?
          pi_uri = pi_uri.content unless pi_uri.nil?
          pi_uri = nil unless !!(pi_uri.match(/https?:\/\/(www.)?pluggedin.com\/(videos|movies)/))
        end
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

          self.kim_sex = sex || nil
          self.kim_violence = violence || nil
          self.kim_language = profanity || nil
        rescue nil
        end
      end

      self.pluggedin_url = pi_uri
      self.kidsinmind_url = kim_uri

    rescue nil
    end
  end

  def load_amazon_information!
    load_amazon_information
    self.save
  end

  def load_amazon_information
    if self.title
      Amazon::Ecs.options = {
        :associate_tag => Settings.amazon_affiliate,
        :AWS_access_key_id => Settings.aws_key,
        :AWS_secret_key => Settings.aws_secret
      }

      res = Amazon::Ecs.item_search("#{self.title} #{self.year}", :search_index => 'All')

      self.amazon_url = res.items.first.get('DetailPageURL') if res.is_valid_request? and not res.has_error? and res.items.first
    end
  end

  def load_all_information!
    load_all_information
    self.save
  end

  def load_all_information
    load_release_information
    load_posters
    load_reviews
    load_amazon_information
  end

  def refresh_information!
    refresh_information
    self.save
  end

  def refresh_information
    load_release_information
    load_reviews
    load_amazon_information
  end

  def async_load_all_information
    InformationLoader.perform_async(self.id, 'all')
  end

  def async_refresh_information
    InformationLoader.perform_async(self.id, 'refresh')
  end

  def async_refresh_posters
    InformationLoader.perform_async(self.id, 'posters')
  end

  def self.search(title)
    return [] if title.nil? or title.empty?
    movies = []
    begin
      uri = "http://api.themoviedb.org/2.1/Movie.search/en-US/json/#{Settings.tmdb_key}/#{CGI::escape(title)}"
      result = Curl::Easy.perform(uri).body_str
      unless !!(result.match(/^<h1>Not Found/)) or !!(result.match(/^\["Nothing found/))
        movies = JSON.parse(result)
        unless movies.empty?
          movies = movies.map do |i|
            hash = {
              title: i['name'],
              slug: i['imdb_id'],
              mpaa_rating: i['certification']
            }
            hash[:poster_url] = i['posters'].first['image']['url'] if i['posters'].first
            hash[:poster_url] ||= '/assets/defaults/thumb_poster.png'
            hash[:year] = i['released'].split(/-/).first.to_i if i['released']
            Hashie::Mash.new(hash)
          end
        end
      end
    rescue nil
      return []
    end
    movies
  end

end
