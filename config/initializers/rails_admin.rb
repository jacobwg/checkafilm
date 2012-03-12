# RailsAdmin config file. Generated on March 12, 2012 11:00
# See github.com/sferik/rails_admin for more informations

RailsAdmin.config do |config|

  # If your default_local is different from :en, uncomment the following 2 lines and set your default locale here:
  # require 'i18n'
  # I18n.default_locale = :de

  config.current_user_method { current_user } # auto-generated

  # If you want to track changes on your models:
  # config.audit_with :history, User

  # Or with a PaperTrail: (you need to install it first)
  # config.audit_with :paper_trail, User

  # Set the admin name here (optional second array element will appear in a beautiful RailsAdmin red ©)
  config.main_app_name = ['Check a Flick', 'Admin']
  # or for a dynamic name:
  # config.main_app_name = Proc.new { |controller| [Rails.application.engine_name.titleize, controller.params['action'].titleize] }


  #  ==> Global show view settings
  # Display empty fields in show views
  # config.compact_show_view = false

  #  ==> Global list view settings
  # Number of default rows per-page:
  # config.default_items_per_page = 20

  #  ==> Included models
  # Add all excluded models here:
  # config.excluded_models = [Movie, Subtitle]

  # Add models here if you want to go 'whitelist mode':
  config.included_models = [Movie, Subtitle]

  # Application wide tried label methods for models' instances
  # config.label_methods << :description # Default is [:name, :title]

  #  ==> Global models configuration
  # config.models do
  #   # Configuration here will affect all included models in all scopes, handle with care!
  #
  #   list do
  #     # Configuration here will affect all included models in list sections (same for show, export, edit, update, create)
  #
  #     fields_of_type :date do
  #       # Configuration here will affect all date fields, in the list section, for all included models. See README for a comprehensive type list.
  #     end
  #   end
  # end
  #
  #  ==> Model specific configuration
  # Keep in mind that *all* configuration blocks are optional.
  # RailsAdmin will try his best to provide the best defaults for each section, for each field.
  # Try to override as few things as possible, in the most generic way. Try to avoid setting labels for models and attributes, use ActiveRecord I18n API instead.
  # Less code is better code!
  # config.model MyModel do
  #   # Cross-section field configuration
  #   object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #   label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #   label_plural 'My models'      # Same, plural
  #   weight -1                     # Navigation priority. Bigger is higher.
  #   parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #   navigation_label              # Sets dropdown entry's name in navigation. Only for parents!
  #   # Section specific configuration:
  #   list do
  #     filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #     items_per_page 100    # Override default_items_per_page
  #     sort_by :id           # Sort column (default is primary key)
  #     sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     # Here goes the fields configuration for the list view
  #   end
  # end


  config.model Movie do

    object_label_method :title_with_year

    configure :subtitles, :has_many_association
    configure :id, :integer
    configure :imdbid, :string
    configure :title, :string
    configure :year, :integer
    configure :mpaa_rating, :string
    configure :plot_summary, :text
    configure :plot_details, :text
    configure :poster, :carrierwave
    configure :backdrop, :carrierwave
    configure :runtime, :string
    configure :rating, :string
    configure :votes, :string
    configure :tmdbid, :string
    configure :imdb_url, :string
    configure :tmdb_url, :string
    configure :pluggedin_url, :string
    configure :kidsinmind_url, :string
    configure :kim_sex, :integer
    configure :kim_violence, :integer
    configure :kim_language, :integer
    configure :created_at, :datetime
    configure :updated_at, :datetime
    configure :status, :string
    configure :slug, :string

    list do
      field :poster
      field :title
      field :year
      field :mpaa_rating do
        label 'MPAA Rating'
      end
      field :rating
      field :imdbid do
        label 'IMDb'
        pretty_value do
          #bindings[:view].tag(:a, { :href => bindings[:object].logo_url }) << value
          bindings[:view].link_to 'IMDb', "http://www.imdb.com/title/#{value}/", :target => '_blank'
        end
      end
    end

    show do
      field :title
      field :year
      field :runtime
      field :mpaa_rating do
        label 'MPAA Rating'
      end
      field :rating do
        label 'IMDb Rating'
      end
      field :votes do
        label 'IMDb Votes'
      end

      field :plot_summary
      field :plot_details

      field :imdb_url do
        label 'IMDb Entry'
        formatted_value do
          bindings[:view].link_to value, value, :target => '_blank'
        end
      end
      field :tmdb_url do
        label 'TMDb Entry'
        formatted_value do
          bindings[:view].link_to value, value, :target => '_blank'
        end
      end
      field :pluggedin_url do
        label 'Plugged In Review'
        formatted_value do
          bindings[:view].link_to value, value, :target => '_blank'
        end
      end
      field :kidsinmind_url do
        label 'Kids In Mind Review'
        formatted_value do
          bindings[:view].link_to value, value, :target => '_blank'
        end
      end

      field :poster
      field :backdrop

      field :status
    end

    edit do

      group :basic_information
      group :details do
        active false
      end
      group :external_links do
        active false
      end
      group :media do
        active false
      end
      group :subtitles do
        active false
      end

      field :title do
        group :basic_information
      end
      field :year do
        group :basic_information
      end
      field :runtime do
        group :basic_information
      end
      field :mpaa_rating do
        label 'MPAA Rating'
        group :basic_information
      end
      field :rating do
        label 'IMDb Rating'
        group :basic_information
      end
      field :votes do
        label 'IMDb Votes'
        group :basic_information
      end

      field :plot_summary do
        group :details
      end
      field :plot_details do
        group :details
      end

      field :imdb_url do
        label 'IMDb Entry'
        group :external_links
      end
      field :tmdb_url do
        label 'TMDb Entry'
        group :external_links
      end
      field :pluggedin_url do
        label 'Plugged In Review'
        group :external_links
      end
      field :kidsinmind_url do
        label 'Kids In Mind Review'
        group :external_links
      end

      field :poster do
        group :media
      end
      field :backdrop do
        group :media
      end

      field :status do
        group :basic_information
      end

      field :subtitles do
        group :subtitles
      end

    end


  end

  config.model Subtitle do
    configure :movie, :belongs_to_association
    configure :id, :integer
    configure :start_time, :integer
    configure :end_time, :integer
    configure :text, :text
    configure :cleaned_text, :text
    configure :movie_id, :integer do
      hidden true
    end
    configure :created_at, :datetime
    configure :updated_at, :datetime
  end


  # Your model's configuration, to help you get started:

  # All fields marked as 'hidden' won't be shown anywhere in the rails_admin unless you mark them as visible. (visible(true))

  # config.model Movie do
  #   # Found associations:
  #     configure :subtitles, :has_many_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :imdbid, :string
  #     configure :title, :string
  #     configure :year, :string
  #     configure :mpaa_rating, :string
  #     configure :plot_summary, :text
  #     configure :plot_details, :text
  #     configure :poster, :carrierwave
  #     configure :backdrop, :carrierwave
  #     configure :runtime, :string
  #     configure :rating, :string
  #     configure :votes, :string
  #     configure :tmdbid, :string
  #     configure :imdb_url, :string
  #     configure :tmdb_url, :string
  #     configure :pluggedin_url, :string
  #     configure :kidsinmind_url, :string
  #     configure :kim_sex, :integer
  #     configure :kim_violence, :integer
  #     configure :kim_language, :integer
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime
  #     configure :status, :string
  #     configure :slug, :string   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Subtitle do
  #   # Found associations:
  #     configure :movie, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :start_time, :integer
  #     configure :end_time, :integer
  #     configure :text, :text
  #     configure :cleaned_text, :text
  #     configure :movie_id, :integer         # Hidden
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
end
