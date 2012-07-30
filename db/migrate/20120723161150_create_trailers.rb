class CreateTrailers < ActiveRecord::Migration
  def change
    create_table :trailers do |t|
      t.string :url
      t.integer :title_id

      t.timestamps
    end
  end
end
