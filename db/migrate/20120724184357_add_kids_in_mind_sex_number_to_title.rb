class AddKidsInMindSexNumberToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :kids_in_mind_sex_number, :integer
  end
end
