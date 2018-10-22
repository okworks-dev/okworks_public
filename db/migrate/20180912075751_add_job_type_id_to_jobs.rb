class AddJobTypeIdToJobs < ActiveRecord::Migration[5.2]
  def change
    add_reference :jobs, :job_type, foreign_key: true
  end
end
