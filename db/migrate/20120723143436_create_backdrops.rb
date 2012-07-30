class CreateBackdrops < ActiveRecord::Migration
  def change
    create_table :backdrops do |t|
      t.string :image
      t.string :original_url

      t.timestamps
    end
  end
end
