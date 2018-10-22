class CreateJobSkills < ActiveRecord::Migration[5.2]
  def change
    create_table :job_skills do |t|
      t.references :job, foreign_key: true
      t.references :skill, foreign_key: true

      t.timestamps
    end
  end
end
