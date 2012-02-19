class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.string :imdbid
      t.string :title
      t.string :year
      t.string :mpaa_rating
      t.string :plot_summary
      t.string :plot_details
      t.string :poster
      t.string :backdrop
      t.string :runtime
      t.string :rating
      t.string :votes
      t.string :tmdbid
      t.string :imdb_url
      t.string :tmdb_url
      t.string :pluggedin_url
      t.string :kidsinmind_url
      t.integer :kim_sex
      t.integer :kim_violence
      t.integer :kim_language

      t.timestamps
    end
  end
end
