class AddRequiredSkillToJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :jobs, :required_skill, :text
  end
end
