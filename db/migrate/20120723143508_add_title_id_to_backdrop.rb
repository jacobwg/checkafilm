class AddTitleIdToBackdrop < ActiveRecord::Migration
  def change
    add_column :backdrops, :title_id, :integer
  end
end
