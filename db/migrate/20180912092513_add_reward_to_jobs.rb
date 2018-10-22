class AddRewardToJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :jobs, :reward_type, :string
    add_column :jobs, :min_reward, :float
    add_column :jobs, :max_reward, :float
  end
end
