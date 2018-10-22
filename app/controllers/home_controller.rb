class HomeController < ApplicationController
  include HomeHelper

  JOB_LIMIT = 10
  before_action :set_select_box, :set_skill_amont_charts, :set_skill_amont_charts_sp, :set_median_rewards_by_skills, :set_median_rewards_by_skills_sp
  before_action :set_high_reward_ranking, only: :index

  def index
    @all_job_count = Job.enabled.count.to_s(:delimited)
    @q = Job.enabled.order(created_at: 'DESC').limit(JOB_LIMIT).ransack(params[:q])
    @jobs = @q.result(distinct: true)
    @logos = ['prosheet_logo.png', 'pebank.png', 'levtech.png', 'midworks.png', 'itpropartners.png'].take(12)
  end

private   

  def set_high_reward_ranking
    @high_reward_jobs = Job.enabled.order(max_reward: 'DESC').limit(10)
  end
end
