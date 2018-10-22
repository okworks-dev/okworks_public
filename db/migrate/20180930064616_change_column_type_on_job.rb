class ChangeColumnTypeOnJob < ActiveRecord::Migration[5.2]
  def up
    change_column :jobs, :key, :text
  end

  def down
    change_column :jobs, :key, :string
  end
end
