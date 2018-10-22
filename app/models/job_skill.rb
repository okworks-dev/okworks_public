class JobSkill < ApplicationRecord
  belongs_to :job
  belongs_to :skill
end
