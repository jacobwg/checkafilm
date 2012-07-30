class AddRottenTomatoesCriticsScoreToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :rotten_tomatoes_critics_score, :float
  end
end
