class AddKidsInMindLanguageNumberToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :kids_in_mind_language_number, :integer
  end
end
