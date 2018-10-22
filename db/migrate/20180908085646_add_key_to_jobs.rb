class AddKeyToJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :jobs, :key, :string
  end
end
