class AddTmdbRatingToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :tmdb_rating, :float
  end
end
