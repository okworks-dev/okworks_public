class CreateJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :jobs do |t|
      t.references :site
      t.string :title

      t.timestamps
    end
  end
end
