class CreateSkills < ActiveRecord::Migration[5.2]
  def change
    create_table :skills do |t|
      t.string :name
      t.integer :priority, default: 0

      t.timestamps
    end
  end
end
