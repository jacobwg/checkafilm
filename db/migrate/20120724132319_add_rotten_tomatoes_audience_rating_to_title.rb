class AddRottenTomatoesAudienceRatingToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :rotten_tomatoes_audience_rating, :string
  end
end
