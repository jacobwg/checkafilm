class AddRottenTomatoesCriticsConsensusToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :rotten_tomatoes_critics_consensus, :string
  end
end
