class AddAverageRewardToJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :jobs, :average_reward, :integer
  end
end
