class AddTmdbVotesToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :tmdb_votes, :integer
  end
end
