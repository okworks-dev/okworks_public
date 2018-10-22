class ApplicationController < ActionController::Base
  before_action :set_subscription_config

  def set_select_box
    @skills = Skill.all
    @job_types = JobType.all
    @work_days = [['週1日', 1], ['週2日', 2], ['週3日', 3], ['週4日' ,4], ['週5日', 5]]
    @average_rewards = [['1万円以上', 1], ['2万円以上', 2], ['3万円以上', 3], ['4万円以上' ,4], ['5万円以上', 5]]
  end

  def set_subscription_config
    @skills = Skill.all
    @job_types = JobType.all
    @subscription_skill = Skill.find_by(id: params.dig('q', 'skills_id_eq')).try(:id)
    @subscription_job_type = JobType.find_by(id: params.dig('q', 'job_type_id_eq')).try(:id)
  end
end
