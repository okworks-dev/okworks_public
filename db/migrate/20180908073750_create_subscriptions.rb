class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.string :email
      t.text :conditions

      t.timestamps
    end
  end
end
