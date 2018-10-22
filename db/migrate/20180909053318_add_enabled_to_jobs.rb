class AddEnabledToJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :jobs, :enabled, :boolean
  end
end
