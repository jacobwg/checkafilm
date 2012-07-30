class AddKidsInMindViolenceNumberToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :kids_in_mind_violence_number, :integer
  end
end
