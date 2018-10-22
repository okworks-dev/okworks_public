class AddDaysToJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :jobs, :max_day, :integer
    add_column :jobs, :min_day, :integer
  end
end
