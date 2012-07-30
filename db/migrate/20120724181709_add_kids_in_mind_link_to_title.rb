class AddKidsInMindLinkToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :kids_in_mind_link, :string
  end
end
