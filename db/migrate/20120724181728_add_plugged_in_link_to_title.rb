class AddPluggedInLinkToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :plugged_in_link, :string
  end
end
