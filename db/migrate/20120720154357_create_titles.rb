class CreateTitles < ActiveRecord::Migration
  def change
    create_table :titles do |t|
      t.string :name
      t.text :plot_summary
      t.text :plot_details
      t.string :mpaa_rating
      t.date :release_date
      t.float :imdb_rating
      t.integer :imdb_votes
      t.string :imdb_id
      t.string :tmdb_id

      t.timestamps
    end
  end
end
