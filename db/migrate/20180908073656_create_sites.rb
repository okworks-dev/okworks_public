class CreateSites < ActiveRecord::Migration[5.2]
  def change
    create_table :sites do |t|
      t.string :name
      t.string :url
      t.string :logo_image_url
      t.text :detail

      t.timestamps
    end
  end
end
