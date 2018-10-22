class Job < ApplicationRecord
  belongs_to :job_type
  belongs_to :site
  has_many :job_skills, :dependent => :destroy
  has_many :skills, through: :job_skills
  scope :enabled, -> { where(enabled: true) }

  validates :site_id, :title, :job_type_id, :max_day, :min_day, 
            :reward_type, :location, :average_reward, :detail, :required_skill, presence: true
  validates :remote_ok, :enabled, inclusion: { in: [true, false] }
  validates :key, uniqueness: true

  def related_jobs
    skill_ids = self.skills.pluck(:id)
    related_job_skills = JobSkill.where(skill_id: skill_ids)
    Job.where(id: related_job_skills.pluck(:job_id)).order(id: 'DESC').limit(12)
  end

  def self.subscription_mailer_jobs(subscription, limit = 5)
    query = {"skills_id_eq"=> subscription.conditions[:skill_id], "job_type_id_eq"=> subscription.conditions[:job_type_id]}
    q = Job.ransack(query)
    jobs = q.result(distinct: true).includes(:job_type, :skills).order(created_at: 'DESC').limit(limit)
  end

  def self.search_jobs(search_params, days_params)
    # Ransackを使用
    if days_params.blank?
      job = Job.enabled
    else
      job = Job.enabled.where(Job.arel_table[:min_day].eq(days_params).or(Job.arel_table[:max_day].eq(days_params)))
    end
    
    if search_params
      q = job.search(search_params)
      jobs = q.result(distinct: true).includes(:job_type, :skills)
    else
      q = job.search
      jobs = job.includes(:job_type, :skills)
    end

    jobs = jobs.order(created_at: :desc)

    return jobs, q
  end
end