class AddJobTypeDetailToJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :jobs, :job_type_detail, :string
  end
end
