class AddDetailToJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :jobs, :detail, :text
  end
end
