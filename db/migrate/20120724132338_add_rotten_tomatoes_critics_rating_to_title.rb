class AddRottenTomatoesCriticsRatingToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :rotten_tomatoes_critics_rating, :string
  end
end
