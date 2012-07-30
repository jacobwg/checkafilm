class AddRottenTomatoesAudienceScoreToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :rotten_tomatoes_audience_score, :float
  end
end
